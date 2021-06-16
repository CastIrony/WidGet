//
//  ContentPanelForm.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/28/20.
//

import AStack
import DominantColor
import PhotosUI
import SwiftUI

let outerPadding: CGFloat = 16
let innerPadding: CGFloat = 8

struct ContentPanelForm: View {
    @Binding var contentPanel: ContentPanelModel
    @Binding var isSelected: Bool

    @State var labelWidth: CGFloat = 120
    let isLoading: Bool

    let panelActions: PanelActions

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: innerPadding) {
            AHStack {
                Label(title: { contentText }, icon: { contentIcon })
                    .font(.title2.weight(.semibold))
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 15)
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.spring()) { isSelected.toggle(); panelActions.scroll() } }

                ZStack {
                    panelActionButton()
                        .opacity(isSelected ? 1 : 0)
                }
                .layoutPriority(-1)
            }
            .padding(.vertical, -14)

            if isSelected {
                FormDivider()

                if contentPanel.contentType.isRemoteContentType {
                    URLRow(contentPanel: $contentPanel,
                           fieldName: "URL",
                           fieldKeyPath: \.targetURLString,
                           showURLFieldEditor: panelActions.showURLFieldEditor,
                           clear: clear,
                           loadContent: panelActions.loadContent,
                           isLoading: isLoading)

                    if contentPanel.errorString?.count ?? 0 > 0 {
                        ErrorRow(errorString: contentPanel.errorString ?? "")
                    }

                    if !isLoading {
                        ChildContentRow(contentItems: contentPanel.contentItems, lastRefreshString: lastRefreshString, loadContent: panelActions.loadContent, isLoading: isLoading)

                        if contentPanel.contentType.isRemoteFeedType {
                            FeedStyleRow(contentPanel: $contentPanel, labelWidth: labelWidth).id("\(contentPanel.id) feed style")
                        }
                    }
                }

                if !isLoading {
                    contentPanelForm
                }
            }
        }
        .padding(outerPadding)
        .font(.body)
        .background((colorScheme == .dark ? Color.black : Color.white).opacity(isSelected ? 0.5 : 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(isSelected ? 0.35 : 0.2) : Color.black.opacity(isSelected ? 0.1 : 0.05)))
        .padding(.horizontal, 8)
        .modifier(ContentPanelFormDeletionModifier(delete: { withAnimation { panelActions.delete() } }))
        .padding(.top, 20)
        .accessibilityElement(children: .contain)
        .accessibility(label: Text(contentPanel.contentType.description))
        .accessibilityAction(named: "Edit Panel") { isSelected = true }
        .applyIf(panelActions.bringToFront != nil) { $0.accessibilityAction(named: "Bring to Front") { panelActions.bringToFront?() } }
        .applyIf(panelActions.bringForward != nil) { $0.accessibilityAction(named: "Bring Forward") { panelActions.bringForward?() } }
        .applyIf(panelActions.sendBackward != nil) { $0.accessibilityAction(named: "Send Backward") { panelActions.sendBackward?() } }
        .applyIf(panelActions.sendToBack != nil) { $0.accessibilityAction(named: "Send to Back") { panelActions.sendToBack?() } }
        .accessibilityAction(named: "Duplicate") { panelActions.duplicate() }
        .accessibilityAction(named: "Reset Frame") { panelActions.resetFrame() }
        .accessibilityAction(named: "Delete Panel") { panelActions.delete() }

        .onPreferenceChange(LabelWidthPreferenceKey.self) {
            newValue in

            labelWidth = newValue
        }
    }

    @ViewBuilder
    var contentPanelForm: some View {
        switch contentPanel.contentType {
        case .text: textPanelForm
        case .image: imagePanelForm
        case .remoteResource: remoteResourcePanelForm
        case .remoteImage: remoteImagePanelForm
        case .remoteFeedList: remoteFeedListPanelForm
        case .remoteFeedGrid: remoteFeedGridPanelForm
        case .remoteCalendar: remoteFeedCalendarPanelForm
        case .link: linkPanelForm
        case .solidColor: solidColorForm
        case .gradient: gradientForm
        }
    }

    var lastRefreshString: String {
        guard let lastRefresh = contentPanel.lastRefresh else { return "--" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: lastRefresh)
    }

    func clear() {
        withAnimation(.spring()) {
            contentPanel.contentType = .remoteResource
        }

        contentPanel.resourceURL = nil
        contentPanel.errorString = nil
        contentPanel.contentItems = []
        contentPanel.lastRefresh = nil
    }

    func panelActionButton() -> some View {
        Menu {
            if panelActions.bringToFront != nil { Button(action: panelActions.bringToFront!) { Label("Bring To Front", systemImage: "square.3.stack.3d.top.fill") } }
            if panelActions.bringForward != nil { Button(action: panelActions.bringForward!) { Label("Bring Forward", systemImage: "square.2.stack.3d.top.fill") } }
            if panelActions.sendBackward != nil { Button(action: panelActions.sendBackward!) { Label("Send Backward", systemImage: "square.2.stack.3d.bottom.fill") } }
            if panelActions.sendToBack != nil { Button(action: panelActions.sendToBack!) { Label("Send To Back", systemImage: "square.3.stack.3d.bottom.fill") } }

            if panelActions.sendToBack != nil || panelActions.sendBackward != nil || panelActions.bringForward != nil || panelActions.bringToFront != nil
            {
                Divider()
            }

            Button(action: panelActions.duplicate) { Label("Duplicate Content", systemImage: "rectangle.on.rectangle") }
            Button(action: panelActions.resetFrame) { Label("Reset Frame", systemImage: "arrow.uturn.backward") }
            Divider()
            Button(role: .destructive, action: panelActions.delete) { Label("Delete Panel", systemImage: "minus.circle.fill") }
        }
        label: {
            Button(action: {}) { Label("Actions", systemImage: "gearshape.fill").labelStyle(IconOnlyLabelStyle()).foregroundColor(.primary) }.buttonStyle(FormButtonStyle())
        }
        .layoutPriority(-1)
    }

    struct PanelActions {
        let bringToFront: (() -> Void)?
        let bringForward: (() -> Void)?
        let sendBackward: (() -> Void)?
        let sendToBack: (() -> Void)?
        let duplicate: () -> Void
        let resetFrame: () -> Void
        let delete: () -> Void

        var scroll: () -> Void
        var loadContent: () -> Void

        let showTextFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, String>, _ fieldName: String) -> Void
        let showURLFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, String>, _ fieldName: String) -> Void
        let showColorFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, HSBColor>, _ fieldName: String) -> Void
        let showFontFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, ContentPanelModel.FontModel>, _ fieldName: String) -> Void
    }
}

extension ContentPanelForm {
    @ViewBuilder
    var textPanelForm: some View {
        TextRow(contentPanel: $contentPanel, fieldName: "Text", fieldKeyPath: \.titleText, showTextFieldEditor: panelActions.showTextFieldEditor, labelWidth: labelWidth)
        ColorRow(contentPanel: $contentPanel, fieldName: "Text Color", fieldKeyPath: \.foregroundColor, showColorFieldEditor: panelActions.showColorFieldEditor, labelWidth: labelWidth)
        FontRow(contentPanel: $contentPanel, fieldName: "Font", fieldKeyPath: \.titleFont, showFontFieldEditor: panelActions.showFontFieldEditor, labelWidth: labelWidth)
        NumberRow(title: "Text Size:", value: $contentPanel.titleFont.size, minimum: 10, maximum: 100, step: 1, labelWidth: labelWidth)
        LinkURLRow(contentPanel: $contentPanel, fieldName: "Link URL", fieldKeyPath: \.linkURLString, showURLFieldEditor: panelActions.showURLFieldEditor, labelWidth: labelWidth)
    }

    @ViewBuilder
    var imagePanelForm: some View {
        ImageRow(contentPanel: $contentPanel, labelWidth: labelWidth, showingImagePickerLight: contentPanel.image.lightIdentifier == nil)
        ImageResizingModeRow(contentPanel: $contentPanel, labelWidth: labelWidth)
        LinkURLRow(contentPanel: $contentPanel, fieldName: "Link URL", fieldKeyPath: \.linkURLString, showURLFieldEditor: panelActions.showURLFieldEditor, labelWidth: labelWidth)
    }

    @ViewBuilder
    var linkPanelForm: some View {
        LinkURLRow(contentPanel: $contentPanel, fieldName: "Link URL", fieldKeyPath: \.linkURLString, showURLFieldEditor: panelActions.showURLFieldEditor, labelWidth: labelWidth)
    }

    @ViewBuilder
    var solidColorForm: some View {
        ColorRow(contentPanel: $contentPanel, fieldName: "Color", fieldKeyPath: \.solidColor, showColorFieldEditor: panelActions.showColorFieldEditor, labelWidth: labelWidth)
        LinkURLRow(contentPanel: $contentPanel, fieldName: "Link URL", fieldKeyPath: \.linkURLString, showURLFieldEditor: panelActions.showURLFieldEditor, labelWidth: labelWidth)
    }

    @ViewBuilder
    var gradientForm: some View {
        ColorRow(contentPanel: $contentPanel, fieldName: "Start Color", fieldKeyPath: \.gradientColor1, showColorFieldEditor: panelActions.showColorFieldEditor, labelWidth: labelWidth)
        ColorRow(contentPanel: $contentPanel, fieldName: "End Color", fieldKeyPath: \.gradientColor2, showColorFieldEditor: panelActions.showColorFieldEditor, labelWidth: labelWidth)
        NumberRow(title: "Angle:", value: gradientAngleBinding, minimum: 0, maximum: 360, step: 15, labelWidth: labelWidth)
        LinkURLRow(contentPanel: $contentPanel, fieldName: "Link URL", fieldKeyPath: \.linkURLString, showURLFieldEditor: panelActions.showURLFieldEditor, labelWidth: labelWidth)
    }

    @ViewBuilder
    var remoteResourcePanelForm: some View {
        EmptyView()
    }

    @ViewBuilder
    var remoteImagePanelForm: some View {
        ImageRow(contentPanel: $contentPanel, labelWidth: labelWidth, showingImagePickerLight: false)
        ImageResizingModeRow(contentPanel: $contentPanel, labelWidth: labelWidth)
        LinkURLRow(contentPanel: $contentPanel, fieldName: "Link URL", fieldKeyPath: \.linkURLString, showURLFieldEditor: panelActions.showURLFieldEditor, labelWidth: labelWidth)
    }

    @ViewBuilder
    var remoteFeedListPanelForm: some View {
        FormDivider()

        Group {
            NumberRow(title: "Start At:", value: contentItemOffsetBinding, minimum: 1, maximum: 20, step: 1, labelWidth: labelWidth)
            FormDivider().padding(.leading, labelWidth)
            NumberRow(title: "Spacing:", value: $contentPanel.contentSpacing, minimum: 0, maximum: 50, step: 1, labelWidth: labelWidth)
            ColorRow(contentPanel: $contentPanel, fieldName: "Text Color", fieldKeyPath: \.foregroundColor, showColorFieldEditor: panelActions.showColorFieldEditor, labelWidth: labelWidth)
        }

        FormDivider()

        Group {
            FontRow(contentPanel: $contentPanel, fieldName: "Title Font", fieldKeyPath: \.titleFont, showFontFieldEditor: panelActions.showFontFieldEditor, labelWidth: labelWidth)
            NumberRow(title: "Title Size:", value: $contentPanel.titleFont.size, minimum: 10, maximum: 30, step: 1, labelWidth: labelWidth)
            NumberRow(title: "Title Lines:", value: titleLinesBinding, minimum: 1, maximum: 6, step: 1, labelWidth: labelWidth)
        }

        FormDivider()

        Group {
            FontRow(contentPanel: $contentPanel, fieldName: "Body Font", fieldKeyPath: \.bodyFont, showFontFieldEditor: panelActions.showFontFieldEditor, labelWidth: labelWidth)
            NumberRow(title: "Body Size:", value: $contentPanel.bodyFont.size, minimum: 10, maximum: 30, step: 1, labelWidth: labelWidth)
            NumberRow(title: "Body Lines:", value: bodyLinesBinding, minimum: 0, maximum: 6, step: 1, labelWidth: labelWidth)
        }
    }

    @ViewBuilder
    var remoteFeedGridPanelForm: some View {
        FormDivider()

        Group {
            NumberRow(title: "Columns:", value: gridColumnsBinding, minimum: 1, maximum: 5, step: 1, labelWidth: labelWidth)
            NumberRow(title: "Rows:", value: gridRowsBinding, minimum: 1, maximum: 5, step: 1, labelWidth: labelWidth)
            NumberRow(title: "Start at:", value: contentItemOffsetBinding, minimum: 1, maximum: 20, step: 1, labelWidth: labelWidth)
        }

        FormDivider()

        Group {
            NumberRow(title: "Spacing:", value: $contentPanel.contentSpacing, minimum: 0, maximum: 20, step: 1, labelWidth: labelWidth)
//            NumberRow(title: "Radius:",  value: $contentPanel.thumbnailCornerRadius, minimum: 0, maximum: 20, labelWidth: labelWidth)
        }
    }

    @ViewBuilder
    var remoteFeedCalendarPanelForm: some View {
        EmptyView()
        ColorRow(contentPanel: $contentPanel, fieldName: "Text Color", fieldKeyPath: \.foregroundColor, showColorFieldEditor: panelActions.showColorFieldEditor, labelWidth: labelWidth)
    }

    var gridRowsBinding: Binding<CGFloat> {
        Binding<CGFloat> { CGFloat(contentPanel.gridRows) } set: { contentPanel.gridRows = Int(round($0)) }
    }

    var gridColumnsBinding: Binding<CGFloat> {
        Binding<CGFloat> { CGFloat(contentPanel.gridColumns) } set: { contentPanel.gridColumns = Int(round($0)) }
    }

    var titleLinesBinding: Binding<CGFloat> {
        Binding<CGFloat> { CGFloat(contentPanel.titleNumberOfLines) } set: { contentPanel.titleNumberOfLines = Int(round($0)) }
    }

    var bodyLinesBinding: Binding<CGFloat> {
        Binding<CGFloat> { CGFloat(contentPanel.bodyNumberOfLines) } set: { contentPanel.bodyNumberOfLines = Int(round($0)) }
    }

    var contentItemOffsetBinding: Binding<CGFloat> {
        // Add 1 to turn a 0-based offset into a 1-based 'start at' ordinal

        Binding<CGFloat> { CGFloat(contentPanel.contentItemOffset) + 1 } set: { contentPanel.contentItemOffset = Int(round($0) - 1) }
    }

    var gradientAngleBinding: Binding<CGFloat> {
        // Convert stored radians to displayed degrees

        Binding<CGFloat> { contentPanel.gradientAngle * 180 / CGFloat.pi } set: { contentPanel.gradientAngle = $0 * CGFloat.pi / 180 }
    }
}

extension ContentPanelForm {
    var contentIcon: Image {
        switch contentPanel.contentType {
        case .text: return Image(systemName: "text.bubble")
        case .image: return Image(systemName: "photo")
        case .link: return Image(systemName: "link")
        case .solidColor: return Image(systemName: "rectangle.fill")
        case .gradient: return Image(systemName: "lineweight")
        case .remoteResource: return Image(systemName: "globe")
        case .remoteImage: return Image(systemName: "photo")
        case .remoteFeedList: return Image(systemName: "list.bullet.rectangle")
        case .remoteFeedGrid: return Image(systemName: "rectangle.split.3x3")
        case .remoteCalendar: return Image(systemName: "calendar")
        }
    }

    var contentText: Text {
        switch contentPanel.contentType {
        case .text: return Text("Text")
        case .image: return Text("Image")
        case .link: return Text("Link")
        case .solidColor: return Text("Solid Color")
        case .gradient: return Text("Gradient")
        case .remoteResource: return Text("Web Content")
        case .remoteImage: return Text("Remote Image")
        case .remoteFeedList: return Text("Web Feed")
        case .remoteFeedGrid: return Text("Web Feed")
        case .remoteCalendar: return Text("Web Calendar")
        }
    }
}

struct FormDivider: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Divider().frame(height: 1).background(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.25)).padding(.vertical, outerPadding - innerPadding)
    }
}

extension ContentPanelForm {
    struct TextRow: View {
        @Binding var contentPanel: ContentPanelModel

        let fieldName: String
        let fieldKeyPath: WritableKeyPath<ContentPanelModel, String>

        let showTextFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, String>, _ fieldName: String) -> Void

        let labelWidth: CGFloat

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
//            if labelWidth < 10
//            {
//                Text("\(fieldName):")
//                .fontWeight(.semibold)
//                .id(UUID())
//                .measureLabelWidth()
//            }
//            else
//            {
            AHStack(hSpacing: 8, vSpacing: 8) {
                Text("\(fieldName):")
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .frame(minWidth: labelWidth, alignment: .trailing)

                Button(action: { showTextFieldEditor(contentPanel.id, fieldKeyPath, fieldName) }) { Text(contentPanel[keyPath: fieldKeyPath]).frame(maxWidth: .infinity, alignment: .leading) }
                    .buttonStyle(FormButtonStyle())
            }
            .frame(maxWidth: .infinity, minHeight: 35)
//            }
        }
    }

    struct LinkURLRow: View {
        @Binding var contentPanel: ContentPanelModel

        let fieldName: String
        let fieldKeyPath: WritableKeyPath<ContentPanelModel, String>

        let showURLFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, String>, _ fieldName: String) -> Void

        let labelWidth: CGFloat

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
//            if labelWidth < 10
//            {
//                Text("\(fieldName):")
//                .fontWeight(.semibold)
//                .id(UUID())
//                .measureLabelWidth()
//            }
//            else
//            {
            AHStack(hSpacing: 8, vSpacing: 8) {
                Text("\(fieldName):")
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .frame(minWidth: labelWidth, alignment: .trailing)

                Button(action: { showURLFieldEditor(contentPanel.id, fieldKeyPath, fieldName) }) { Text(contentPanel[keyPath: fieldKeyPath]).frame(maxWidth: .infinity, alignment: .leading) }
                    .buttonStyle(FormButtonStyle())
            }
            .frame(maxWidth: .infinity, minHeight: 35)
//            }
        }
    }

    struct URLRow: View {
        @Binding var contentPanel: ContentPanelModel
        let fieldName: String
        let fieldKeyPath: WritableKeyPath<ContentPanelModel, String>
        let showURLFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, String>, _ fieldName: String) -> Void

        let clear: () -> Void
        let loadContent: () -> Void

        let isLoading: Bool

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            AHStack(hSpacing: 8, vSpacing: 8) {
                Button(action: { showURLFieldEditor(contentPanel.id, fieldKeyPath, fieldName) }) { Text(contentPanel[keyPath: fieldKeyPath]).frame(maxWidth: .infinity, alignment: .leading) }
                    .buttonStyle(FormButtonStyle())
                    .opacity(isLoading ? 0.5 : 1.0)
                    .disabled(isLoading)

                Button(action: loadContent) {
                    if isLoading {
                        Color.clear.background(ProgressView()).frame(width: 16, height: 16)
                    } else {
                        Color.clear.background(Image(systemName: contentPanel.contentType == .remoteResource ? "arrow.down" : "arrow.clockwise"))
                            .font(.body.weight(.medium))
                            .frame(width: 16, height: 16)
                    }
                }
                .buttonStyle(FormButtonStyle())
            }
        }
    }

    struct ChildContentRow: View {
        let contentItems: [ContentPanelModel.ItemModel]
        let lastRefreshString: String
        let loadContent: () -> Void
        let isLoading: Bool

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            if contentItems.count > 0 {
                AHStack(hSpacing: 8, vSpacing: 8) {
                    Text("\(contentItems.count) item(s) loaded").font(.body.weight(.semibold))

                    Spacer()

                    Text(lastRefreshString).font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FormDivider()
            }
        }
    }

    struct ErrorRow: View {
        let errorString: String

        var body: some View {
            if errorString.count > 0 {
                Text(errorString)
                    .padding(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
        }
    }

    struct ColorRow: View {
        @Binding var contentPanel: ContentPanelModel
        let fieldName: String
        let fieldKeyPath: WritableKeyPath<ContentPanelModel, ContentPanelModel.ColorModel>
        let showColorFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, HSBColor>, _ fieldName: String) -> Void
        let labelWidth: CGFloat

        @Environment(\.colorScheme) var colorScheme
        @ScaledMetric(wrappedValue: 24, relativeTo: .body) var height: CGFloat

        var body: some View {
//            if labelWidth < 10
//            {
//                Text("\(fieldName):")
//                .fontWeight(.semibold)
//                .id(UUID())
//                .measureLabelWidth()
//            }
//            else
//            {
            AHStack(hSpacing: 8, vSpacing: 8) {
                Text("\(fieldName):")
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .frame(minWidth: labelWidth, alignment: .trailing)

                Button(action: { showColorFieldEditor(contentPanel.id, fieldKeyPath.appending(path: \.lightColor), "\(fieldName)\(contentPanel[keyPath: fieldKeyPath].enableDarkColor ? " (Light)" : "")") })
                    {
                        Text(contentPanel[keyPath: fieldKeyPath].enableDarkColor ? "Light" : "")
                            .font(.body.bold().smallCaps())
                            .padding(.bottom, 1)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FormColorButtonStyle(hsbColor: contentPanel[keyPath: fieldKeyPath.appending(path: \.lightColor)]))
                    .animation(.interactiveSpring())

                if contentPanel[keyPath: fieldKeyPath].enableDarkColor {
                    Button(action: { showColorFieldEditor(contentPanel.id, fieldKeyPath.appending(path: \.darkColor), "\(fieldName) (Dark)") })
                        {
                            Text("Dark")
                                .font(.body.bold().smallCaps())
                                .padding(.bottom, 1)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FormColorButtonStyle(hsbColor: contentPanel[keyPath: fieldKeyPath.appending(path: \.darkColor)]))
                        .animation(.interactiveSpring())
                }

                Button {
                    contentPanel[keyPath: fieldKeyPath].enableDarkColor.toggle()
                }
                label: {
                    Image(systemName: colorScheme == .light ? "circle.righthalf.fill" : "circle.lefthalf.fill")
                        .imageScale(.large)
                        .frame(minWidth: height, minHeight: height)
                }
                .buttonStyle(FormButtonStyle())
                .layoutPriority(-1)
                .animation(.interactiveSpring())
            }
            .frame(minHeight: 35)
//            }
        }
    }

    struct FontRow: View {
        @Binding var contentPanel: ContentPanelModel
        let fieldName: String
        let fieldKeyPath: WritableKeyPath<ContentPanelModel, ContentPanelModel.FontModel>
        let showFontFieldEditor: (_ contentPanelID: UUID, _ keyPath: WritableKeyPath<ContentPanelModel, ContentPanelModel.FontModel>, _ fieldName: String) -> Void
        let labelWidth: CGFloat

        @Environment(\.colorScheme) var colorScheme
        @ScaledMetric(wrappedValue: 24, relativeTo: .body) var height: CGFloat

        var body: some View {
//            if labelWidth < 10
//            {
//                Text("\(fieldName):")
//                .fontWeight(.semibold)
//                .id(UUID())
//                .measureLabelWidth()
//            }
//            else
//            {
            AHStack(hSpacing: 8, vSpacing: 8) {
                Text("\(fieldName):")
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .frame(minWidth: labelWidth, alignment: .trailing)

                Button(action: { showFontFieldEditor(contentPanel.id, fieldKeyPath, "\(fieldName)") })
                    {
                        Text(contentPanel[keyPath: fieldKeyPath].fontName)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: height)
                    }
                    .buttonStyle(FormButtonStyle())

                //                Button(action: { showColorFieldEditor(contentPanel.id, fieldKeyPath.appending(path: \.darkColor), "\(fieldName) - Dark") })
                //                {
                //                    Text("Dark")
                //                    .font(.body.bold().smallCaps())
                //                    .foregroundColor(contentPanel[keyPath: fieldKeyPath.appending(path: \.darkColor)].opticalLuminance > 0.5 ? Color.black : Color.white)
                //                    .padding(.bottom, 1)
                //                    .frame(maxWidth: .infinity)
                //
                //                    .background(
                //                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(contentPanel[keyPath: fieldKeyPath.appending(path: \.darkColor)].uiColor)).padding(-5)
                //                    )
                //                }
                //                .buttonStyle(FormButtonStyle())
            }
            .frame(minHeight: 35)
        }
//        }
    }

    struct FeedStyleRow: View {
        @Binding var contentPanel: ContentPanelModel
        let labelWidth: CGFloat

        let styleOptions = [ContentPanelModel.ContentType.remoteFeedList, ContentPanelModel.ContentType.remoteFeedGrid]

        var body: some View {
            if styleOptions.contains(contentPanel.contentType) {
                AHStack(hSpacing: 8, vSpacing: 8) {
                    Text("Feed Style:")
                        .fontWeight(.semibold)
                        .measureLabelWidth()
                        .frame(minWidth: labelWidth, alignment: .trailing)

                    Picker("Feed Style", selection: $contentPanel.contentType) {
                        ForEach(styleOptions, id: \.self) {
                            $0 == .remoteFeedList ? Image(systemName: "list.bullet.rectangle") : Image(systemName: "rectangle.split.3x3")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .frame(minHeight: 35)
            }
        }
    }

    struct ImageResizingModeRow: View {
        @Binding var contentPanel: ContentPanelModel
        let labelWidth: CGFloat

        let styleOptions = [ContentPanelModel.ImageResizingMode.scaleToFit, ContentPanelModel.ImageResizingMode.scaleToFill, ContentPanelModel.ImageResizingMode.stretch]

        var body: some View {
            if styleOptions.contains(contentPanel.imageResizingMode) {
                AHStack(hSpacing: 8, vSpacing: 8) {
                    Text("Sizing:")
                        .fontWeight(.semibold)
                        .measureLabelWidth()
                        .frame(minWidth: labelWidth, alignment: .trailing)

                    Picker("Sizing", selection: $contentPanel.imageResizingMode) {
                        ForEach(styleOptions, id: \.self) {
                            switch $0 {
                            case .scaleToFit: Text("Fit")
                            case .scaleToFill: Text("Fill")
                            case .stretch: Text("Stretch")
                            default: Text("Full Size")
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .frame(minHeight: 35)
            }
        }
    }

    struct ContentAlignmentRow: View {
        @Binding var contentPanel: ContentPanelModel
        let labelWidth: CGFloat

        let styleOptions = [ContentPanelModel.ImageResizingMode.scaleToFit, ContentPanelModel.ImageResizingMode.scaleToFill, ContentPanelModel.ImageResizingMode.stretch, ContentPanelModel.ImageResizingMode.fullSize]

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            if styleOptions.contains(contentPanel.imageResizingMode) {
                AHStack(hSpacing: 8, vSpacing: 8) {
                    Text("Alignment:")
                        .fontWeight(.semibold)
                        .measureLabelWidth()
                        .frame(minWidth: labelWidth, alignment: .trailing)

                    VStack {
                        HStack {
                            Button(action: { contentPanel.contentAlignment = .topLeading }) { Image(systemName: "square.grid.3x3.topleft.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .topLeading ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                            Button(action: { contentPanel.contentAlignment = .top }) { Image(systemName: "square.grid.3x3.topmiddle.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .top ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                            Button(action: { contentPanel.contentAlignment = .topTrailing }) { Image(systemName: "square.grid.3x3.topright.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .topTrailing ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                        }

                        HStack {
                            Button(action: { contentPanel.contentAlignment = .leading }) { Image(systemName: "square.grid.3x3.middleleft.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .leading ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                            Button(action: { contentPanel.contentAlignment = .center }) { Image(systemName: "square.grid.3x3.middle.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .center ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                            Button(action: { contentPanel.contentAlignment = .trailing }) { Image(systemName: "square.grid.3x3.middleright.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .trailing ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                        }

                        HStack {
                            Button(action: { contentPanel.contentAlignment = .bottomLeading }) { Image(systemName: "square.grid.3x3.bottomleft.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .bottomLeading ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                            Button(action: { contentPanel.contentAlignment = .bottom }) { Image(systemName: "square.grid.3x3.bottommiddle.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .bottom ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                            Button(action: { contentPanel.contentAlignment = .bottomTrailing }) { Image(systemName: "square.grid.3x3.bottomright.fill").imageScale(.large).font(.title3).background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(contentPanel.contentAlignment == .bottomTrailing ? Color.black.opacity(0.1) : Color.black.opacity(0)).padding(-5)) }.buttonStyle(FormButtonStyle())
                        }
                    }
                }
                .frame(minHeight: 35)
            }
        }
    }

    struct ImageRow: View {
        @Binding var contentPanel: ContentPanelModel
        let labelWidth: CGFloat

        @State var showingImagePickerLight: Bool
        @State var showingImagePickerDark: Bool = false

        @State var pickedImage: UIImage?

        @Environment(\.insideWidget) var insideWidget
        @Environment(\.colorScheme) var colorScheme

        @ScaledMetric(wrappedValue: 24, relativeTo: .body) var height: CGFloat

        var body: some View {
            if contentPanel.contentType == .image {
                AHStack(hSpacing: 8, vSpacing: 8) {
                    (Text("Image") + Text(":"))
                        .fontWeight(.semibold)
                        .measureLabelWidth()
                        .frame(minWidth: labelWidth, alignment: .trailing)

                    VStack {
                        Button(action: { showingImagePickerLight = true }) {
                            if contentPanel.image.enableDarkIdentifier {
                                VStack {
                                    if contentPanel.image.lightIdentifier == nil {
                                        Image(systemName: "photo.on.rectangle.angled")
                                    }

                                    Text("Light")
                                        .padding(.bottom, 1)
                                }
                                .padding(.horizontal, 4)
                                .padding(8)
                                .background(Material.regular, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .font(.body.bold().smallCaps())
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .frame(minHeight: height * 4)
                                .frame(maxWidth: .infinity)
                            } else {
                                if contentPanel.image.lightIdentifier == nil {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .padding(.horizontal, 4)
                                        .padding(8)
                                        .background(Material.regular, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .font(.body.bold().smallCaps())
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                        .frame(minHeight: height * 4)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Color.clear
                                        .frame(minHeight: height * 4)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .buttonStyle(FormImageButtonStyle(uiImage: ImageCache.shared.image(for: contentPanel.image.lightIdentifier, usePrebaked: false)))
                        .sheet(isPresented: $showingImagePickerLight) { handleImage(for: .light) } content: { ImagePicker(configuration: PHPickerConfiguration(), uiImage: $pickedImage) }
                    }

                    if contentPanel.image.enableDarkIdentifier {
                        VStack {
                            Button(action: { showingImagePickerDark = true }) {
                                VStack {
                                    if contentPanel.image.darkIdentifier == nil {
                                        Image(systemName: "photo.on.rectangle.angled")
                                    }

                                    Text("Dark")
                                        .padding(.bottom, 1)
                                }
                                .padding(.horizontal, 4)
                                .padding(8)
                                .background(Material.regular, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .font(.body.bold().smallCaps())
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .frame(minHeight: height * 4)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FormImageButtonStyle(uiImage: ImageCache.shared.image(for: contentPanel.image.darkIdentifier, usePrebaked: false)))
                            .sheet(isPresented: $showingImagePickerDark) { handleImage(for: .dark) } content: { ImagePicker(configuration: PHPickerConfiguration(), uiImage: $pickedImage) }
                        }
                    }

                    Button {
                        contentPanel.image.enableDarkIdentifier.toggle()
                    }
                    label: {
                        Image(systemName: colorScheme == .light ? "circle.righthalf.fill" : "circle.lefthalf.fill")
                            .imageScale(.large)
                            .frame(minWidth: height, minHeight: height)
                    }
                    .buttonStyle(FormButtonStyle())
                    .layoutPriority(-1)
                    .animation(.interactiveSpring())
                }
                .frame(minHeight: 35)
            } else if
                let imageURL = contentPanel.resourceURL,
                let uiImage = ImageCache.shared.image(for: imageURL.absoluteString, usePrebaked: insideWidget)
            {
                HStack {
                    ZStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.size.width * 0.6)

                        Text("\(Int(uiImage.size.width)) ✕ \(Int(uiImage.size.height))")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(Color.black)
                            .cornerRadius(7)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(minHeight: 35)
            }
        }

        func handleImage(for imageColorScheme: ColorScheme) {
            if
                let pickedImage = pickedImage,
                let imageData = pickedImage.pngData()
            {
                let imageIdentifier = String(describing: UUID())

                print("storeImageData \(pickedImage) \(pickedImage.scale) \(imageIdentifier)")

                ImageCache.shared.storeImageData(imageData, for: imageIdentifier)

                let oldCacheFileURLs = contentPanel.cacheFileURLs

                contentPanel.image.setIdentifier(imageIdentifier, for: imageColorScheme)

                oldCacheFileURLs.subtracting(contentPanel.cacheFileURLs).forEach {
                    do {
                        try FileManager.default.removeItem(at: $0)
                    } catch {
                        dump(error)
                    }
                }

                if let cgImage = pickedImage.cgImage {
                    if let dominantColors = pastelPaletteColors(in: cgImage) {
                        contentPanel.dominantImageColors = dominantColors
                    } else {
                        contentPanel.dominantImageColors = Array(dominantColorsInImage(cgImage, maxSampledPixels: min(cgImage.width * cgImage.height, 10000), accuracy: .high).map { HSBColor(uiColor: UIColor(cgColor: $0)) }.prefix(5))
                    }
                }
            }
        }
    }

    struct NumberRow: View {
        let title: String
        @Binding var value: CGFloat
        let minimum: CGFloat
        let maximum: CGFloat
        let step: CGFloat
        let labelWidth: CGFloat

        var body: some View {
//            if labelWidth < 10
//            {
//                Text(title)
//                .fontWeight(.semibold)
//                .id(UUID())
//                .measureLabelWidth()
//            }
//            else
//            {
            AHStack(hSpacing: 8, vSpacing: 8) {
                Text(title)
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .frame(minWidth: labelWidth, alignment: .trailing)

                FormSlider(value: $value, bounds: ClosedRange(uncheckedBounds: (lower: minimum, upper: maximum)), step: step, labelSpecifier: "%0.0f", backgroundGradient: nil)
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(title))
            .accessibility(value: Text("\(value)"))
            .accessibilityAdjustableAction {
                switch $0 {
                case .increment: value = min(value + step, maximum)
                case .decrement: value = max(value - step, minimum)
                @unknown default: break
                }
            }
        }
//        }
    }
}

extension UIColor {
    func contrastingTextColor() -> UIColor {
        guard
            let rgb = cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil),
            let components = rgb.components
        else {
            return .green
        }

        if components.count < 3 {
            return .red
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)

        return brightness < 0.5 ? .white : .black
    }
}

struct ContentPanelForm_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Light")
                .padding(.bottom, 1)
                .padding(.horizontal, 4)
                .padding(4)
                .background(Material.regular, in: Capsule())
                .font(.body.bold().smallCaps())
                .foregroundColor(.black)
                .frame(minHeight: 24 * 4)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(FormImageButtonStyle(uiImage: UIImage(named: "test")))
    }
}

//        Text("Hello World!")
//        let frame = ContentPanelModel.FrameModel(centerX: 0, centerY: 0, width: 80, height: 80)
//        let contentPanel1 = ContentPanelModel(contentType: .remoteFeedList, title: "Image Foo", frame: frame, resourceURL:URL(string: "https://rss.nytimes.com/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt"), automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//        let contentPanel2 = ContentPanelModel(contentType: .remoteResource, title: "Image Foo", frame: frame, resourceURL:nil, automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//        let contentPanel3 = ContentPanelModel(contentType: .remoteImage, title: "Image Foo", frame: frame, resourceURL:URL(string: "https://rss.nytimes.com/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt"), automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//        let contentPanel4 = ContentPanelModel(contentType: .text, title: "Image Foo", frame: frame, resourceURL:nil, automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//        let contentPanel5 = ContentPanelModel(contentType: .image, title: "Image Foo", frame: frame, resourceURL:nil, automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//
//        let contentPanel6 = ContentPanelModel(contentType: .remoteFeedGrid, title: "Image Foo", frame: frame, resourceURL:URL(string: "https://rss.nytimes.com/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt"), automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//        let contentPanel7 = ContentPanelModel(contentType: .remoteFeedCalendar, title: "Image Foo", frame: frame, resourceURL:URL(string: "https://rss.nytimes.com/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt"), automaticallyRefresh: true, lastRefresh: nil, errorString: nil)
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel1), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel2), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel3), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel4), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel5), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel6), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//
//        ScrollView
//        {
//            ContentPanelForm(contentPanel: Binding.constant(contentPanel7), isSelected: Binding.constant(true), targetURLString: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", scrollTo: {}, bringToFront: {}, bringForward: {}, sendBackward: {}, sendToBack: {} )
//            .background(Color.white.opacity(0.65))
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .padding(20)
//        }
//        .environment(\.sizeCategory, .extraSmall)
//        .background(Color(UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)))
//        .previewLayout(.fixed(width: 375, height: 500))
//    }
// }

struct FormButtonStyle: ButtonStyle {
    struct ButtonView: View {
        let configuration: FormButtonStyle.Configuration

        @ScaledMetric(wrappedValue: 38, relativeTo: .body) var buttonHeight: CGFloat
        @ScaledMetric(wrappedValue: 9, relativeTo: .body) var padding: CGFloat
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            let backgroundColorUnpressed = colorScheme == .light ? Color.white : Color.black
            let backgroundColorPressed = backgroundColorUnpressed.opacity(0.4)
            let backgroundColor = configuration.isPressed ? backgroundColorPressed : backgroundColorUnpressed

            let foregroundColor = colorScheme == .light ? Color.black : Color.white
            let borderColor = colorScheme == .light ? Color.black.opacity(0.22) : Color.white.opacity(0.35)

            return configuration.label
                .foregroundColor(foregroundColor)
                .padding(.horizontal, padding)
                .frame(minWidth: buttonHeight, minHeight: buttonHeight)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 1).fill(backgroundColor))
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(borderColor))
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    public func makeBody(configuration: FormButtonStyle.Configuration) -> some View {
        ButtonView(configuration: configuration)
    }
}

struct FormColorButtonStyle: ButtonStyle {
    struct ButtonView: View {
        let configuration: FormColorButtonStyle.Configuration
        let hsbColor: HSBColor

        @ScaledMetric(wrappedValue: 38, relativeTo: .body) var buttonHeight: CGFloat
        @ScaledMetric(wrappedValue: 9, relativeTo: .body) var padding: CGFloat
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            let backgroundColorUnpressed = colorScheme == .light ? Color.white : Color.black
            let backgroundColorPressed = backgroundColorUnpressed.opacity(0.4)
            let backgroundColor = configuration.isPressed ? backgroundColorPressed : backgroundColorUnpressed

            let borderColor = colorScheme == .light ? Color.black.opacity(0.22) : Color.white.opacity(0.35)
            let foregroundColor = hsbColor.opticalLuminance > 0.5 ? Color.black : Color.white

            return configuration.label
                .foregroundColor(foregroundColor)
                .padding(.horizontal, padding)
                .frame(minWidth: buttonHeight, minHeight: buttonHeight)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 4).fill(Color(hsbColor.uiColor)))
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 4).fill(ImagePaint(image: Image("alpha"))))
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 1).fill(backgroundColor))
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(borderColor))
        }
    }

    let hsbColor: HSBColor

    public func makeBody(configuration: FormButtonStyle.Configuration) -> some View {
        ButtonView(configuration: configuration, hsbColor: hsbColor)
    }
}

struct FormImageButtonStyle: ButtonStyle {
    struct ButtonView: View {
        let configuration: FormImageButtonStyle.Configuration
        let uiImage: UIImage?

        @ScaledMetric(wrappedValue: 38, relativeTo: .body) var buttonHeight: CGFloat
        @ScaledMetric(wrappedValue: 9, relativeTo: .body) var padding: CGFloat
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            let backgroundColorUnpressed = colorScheme == .light ? Color.white : Color.black
            let backgroundColorPressed = backgroundColorUnpressed.opacity(0.4)
            let backgroundColor = configuration.isPressed ? backgroundColorPressed : backgroundColorUnpressed

            let borderColor = colorScheme == .light ? Color.black.opacity(0.22) : Color.white.opacity(0.35)
            let foregroundColor = colorScheme == .light ? Color.black : Color.white

            if let uiImage = uiImage {
                configuration.label
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, padding)
                    .frame(minWidth: buttonHeight, minHeight: buttonHeight)
                    .background(Color.clear.background(Image(uiImage: uiImage).resizable().scaledToFill()).clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous)).padding(3))
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 1).fill(backgroundColor))
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(borderColor))
            } else {
                configuration.label
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, padding)
                    .frame(minWidth: buttonHeight, minHeight: buttonHeight)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 1).fill(backgroundColor))
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(borderColor))
            }
        }
    }

    let uiImage: UIImage?

    public func makeBody(configuration: FormButtonStyle.Configuration) -> some View {
        ButtonView(configuration: configuration, uiImage: uiImage)
    }
}
