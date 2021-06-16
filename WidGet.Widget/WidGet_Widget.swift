//
//  WidGet_Widget.swift
//  WidGet.Widget
//
//  Created by Bernstein, Joel on 7/22/20.
//

import Intents
import SwiftUI
import WidgetKit

func loadWidgetContent(for widgetID: UUID, completion: @escaping (WidgetModel?) -> Void) {
    class WidgetBox {
        init(widgetID: UUID) {
            self.widget = WidgetModel.load(widgetID: widgetID)
        }

        var widget: WidgetModel?
    }

    let box = WidgetBox(widgetID: widgetID)
    let group = DispatchGroup()

    for contentPanelID in box.widget?.contentPanelIDs ?? [] {
        guard
            let contentPanel = box.widget?.contentPanelsByID[contentPanelID],
            contentPanel.contentType.isRemoteContentType,
            let url = contentPanel.resourceURL
        else { print("no url for content panel \(contentPanelID)"); continue }

        group.enter()

        RemoteResourceLoader.loadResource(from: url) {
            response, _ in

            if response?.contentType == .remoteImage {
                if let imageData = response?.data {
                    ImageCache.shared.storeImageData(imageData, for: url.absoluteString)
                }
            }

            if response?.contentItems.count == 0 || box.widget?.contentPanelsByID[contentPanelID]?.contentItems != response?.contentItems
            {
                box.widget?.contentPanelsByID[contentPanelID]?.lastRefresh = Date()
            }

            box.widget?.contentPanelsByID[contentPanelID]?.contentItems = response?.contentItems ?? contentPanel.contentItems

            group.leave()
        }
    }

    group.notify(queue: .main) {
        box.widget?.bakeThumbnails {
            box.widget?.save()

            print("widget updated")

            completion(box.widget)
        }
    }
}

struct SmallProvider: IntentTimelineProvider {
    func placeholder(in _: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: nil, widget: nil, relevance: TimelineEntryRelevance(score: 0))
    }

    public func getSnapshot(for configuration: ConfigurationSmallIntent, in context: Context, completion: @escaping (WidgetEntry) -> Void)
    {
        if let widgetIDString = configuration.userWidget?.identifier, let widgetID = UUID(uuidString: widgetIDString)
        {
            loadWidgetContent(for: widgetID) {
                completion(WidgetEntry(date: Date(), configuration: configuration, widget: $0, relevance: TimelineEntryRelevance(score: Float($0?.priorityScore ?? 0), duration: 1800)))
            }
        } else {
            completion(placeholder(in: context))
        }
    }

    public func getTimeline(for configuration: ConfigurationSmallIntent, in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void)
    {
        getSnapshot(for: configuration, in: context) { completion(Timeline(entries: [$0], policy: .atEnd)) }
    }
}

struct MediumProvider: IntentTimelineProvider {
    func placeholder(in _: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: nil, widget: nil, relevance: TimelineEntryRelevance(score: 0))
    }

    public func getSnapshot(for configuration: ConfigurationMediumIntent, in context: Context, completion: @escaping (WidgetEntry) -> Void)
    {
        if let widgetIDString = configuration.userWidget?.identifier, let widgetID = UUID(uuidString: widgetIDString)
        {
            loadWidgetContent(for: widgetID) {
                completion(WidgetEntry(date: Date(), configuration: configuration, widget: $0, relevance: TimelineEntryRelevance(score: Float($0?.priorityScore ?? 0), duration: 1800)))
            }
        } else {
            completion(placeholder(in: context))
        }
    }

    public func getTimeline(for configuration: ConfigurationMediumIntent, in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void)
    {
        getSnapshot(for: configuration, in: context) { completion(Timeline(entries: [$0], policy: .atEnd)) }
    }
}

struct LargeProvider: IntentTimelineProvider {
    func placeholder(in _: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: nil, widget: nil, relevance: TimelineEntryRelevance(score: 0))
    }

    public func getSnapshot(for configuration: ConfigurationLargeIntent, in context: Context, completion: @escaping (WidgetEntry) -> Void)
    {
        if let widgetIDString = configuration.userWidget?.identifier, let widgetID = UUID(uuidString: widgetIDString)
        {
            loadWidgetContent(for: widgetID) {
                completion(WidgetEntry(date: Date(), configuration: configuration, widget: $0, relevance: TimelineEntryRelevance(score: Float($0?.priorityScore ?? 0), duration: 1800)))
            }
        } else {
            completion(placeholder(in: context))
        }
    }

    public func getTimeline(for configuration: ConfigurationLargeIntent, in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void)
    {
        getSnapshot(for: configuration, in: context) { completion(Timeline(entries: [$0], policy: .atEnd)) }
    }
}

struct WidgetEntry: TimelineEntry {
    public let date: Date
    public let configuration: INIntent?
    public let widget: WidgetModel?
    public let relevance: TimelineEntryRelevance?
}

struct PlaceholderView: View {
    var body: some View {
        Text("Placeholder View")
    }
}

struct WidGet_WidgetEntryView: View {
    var entry: WidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter
    }

    func shouldApplyCornerRadius(contentPanelID: UUID) -> Bool {
        let contentPanel = entry.widget!.contentPanelsByID[contentPanelID]!

        if contentPanel.contentType == .remoteFeedList || contentPanel.contentType == .text {
            return false
        }

        return !contentPanel.frame.isCloseToContainer(size: entry.widget!.widgetSize.deviceFrame)
    }

    var body: some View {
        if let widget = entry.widget {
            ZStack {
                ForEach(widget.contentPanelIDs.reversed(), id: \.self) {
                    contentPanelID in

                    let frame = widget.contentPanelsByID[contentPanelID]!.frame.deviceRect

                    ContentPanelView(contentPanel: Binding.constant(widget.contentPanelsByID[contentPanelID]!), isSelected: Binding.constant(false), isLoading: false)
                        .frame(width: frame.width, height: frame.height, alignment: widget.contentPanelsByID[contentPanelID]?.contentAlignment.alignment ?? .center)
                        .applyIf(shouldApplyCornerRadius(contentPanelID: contentPanelID), apply: { $0.clipShape(ContainerRelativeShape()) })
                        .position(CGPoint(x: frame.midX, y: frame.midY))
                }
            }
            .background(Color(widget.backgroundColor.uiColor(for: colorScheme)))
            .applyIf(widgetFamily == .systemSmall) { $0.widgetURL(widget.mainLinkURL) }
            .environment(\.insideWidget, true)
            .environment(\.widgetColorScheme, colorScheme)
        } else {
//            GeometryReader
//            {
//                geometry in
//
//                VStack
//                {
//                    Text("Screen: \(String(describing: UIScreen.main.bounds.size))")
//                    Text("Widget: \(String(describing: geometry.size))")
//                }
//            }

            let cornerRadius = CGFloat(23.0)
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0.6235829871, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.9488901478, green: 0.3370382543, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.919741599, green: 0, blue: 0.01532902666, alpha: 1)), Color(#colorLiteral(red: 0.7517621157, green: 0, blue: 0.6094596243, alpha: 1))]), startPoint: .top, endPoint: .bottom)

                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .inset(by: 12.0)
                                .fill(Color.white)
                                .shadow(color: Color(#colorLiteral(red: 0.5, green: 0.1775960342, blue: 0, alpha: 1)).opacity(0.6), radius: 1.0, x: 0, y: 1.8)

                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .inset(by: 15.0)
                                .fill(Color(#colorLiteral(red: 0.8537944547, green: 0.9499960396, blue: 1, alpha: 1))) // .fill(Color(#colorLiteral(red: 0.8537944547, green: 0.9499960396, blue: 1, alpha: 1)))

                            Text("WID")
                                .foregroundColor(Color(#colorLiteral(red: 0, green: 0.4245878609, blue: 0.6526296053, alpha: 1)))
                                .font(.system(size: 36.0, weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
                                .offset(x: 0, y: -16.2 - 2.7)

                            Text("GET")
                                .foregroundColor(Color(#colorLiteral(red: 0, green: 0.4245878609, blue: 0.6526296053, alpha: 1)))
                                // .foregroundColor(Color(#colorLiteral(red: 0, green: 0.4274785522, blue: 0.6537857605, alpha: 1)))
                                .font(.system(size: 36.0, weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
                                .offset(x: 0, y: 16.2 - 2.2)
                        }
                        .frame(width: 102.4, height: 102.4)

//                        Text("Edit this widget to pick one that you've made!").font(.system(size: widgetFamily == .systemLarge ? 20 : 12, weight: .bold, design: .rounded)).foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 8)
                        Text("<\(geometry.size.width), \(geometry.size.height)>").font(.system(size: widgetFamily == .systemLarge ? 20 : 12, weight: .bold, design: .rounded)).foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 8)
                    }
                    .unredacted()
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

@main
struct WidGetWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WidGetWidgetSmall()
        WidGetWidgetMedium()
        WidGetWidgetLarge()
    }
}

struct WidGetWidgetSmall: Widget {
    private let kind: String = "WidGet_Widget_Small"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationSmallIntent.self, provider: SmallProvider())
            {
                entry in
                WidGet_WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Small Widget")
            .description("This is a small widget.")
            .supportedFamilies([.systemSmall])
    }
}

struct WidGetWidgetMedium: Widget {
    private let kind: String = "WidGet_Widget_Medium"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationMediumIntent.self, provider: MediumProvider())
            {
                entry in
                WidGet_WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Medium Widget")
            .description("This is a medium widget.")
            .supportedFamilies([.systemMedium])
    }
}

struct WidGetWidgetLarge: Widget {
    private let kind: String = "WidGet_Widget_Large"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationLargeIntent.self, provider: LargeProvider())
            {
                entry in
                WidGet_WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Large Widget")
            .description("This is a large widget.")
            .supportedFamilies([.systemLarge])
    }
}

// struct WidGet_Widget_Previews: PreviewProvider
// {
//    static var previews: some View
//    {
//        WidGet_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: DynamicConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
// }
