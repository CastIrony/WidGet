//
//  ContentPanelView.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/20/20.
//

import SwiftUI

struct ContentPanelView: View {
    @Binding var contentPanel: ContentPanelModel
    @Binding var isSelected: Bool

    let isLoading: Bool

    @Environment(\.widgetColorScheme) var colorScheme

    var color: Color {
        srand48(contentPanel.id.hashValue)
        return Color(hue: drand48(), saturation: 1, brightness: 1)
    }

    var body: some View {
        if isLoading {
            ZStack {
                VisualEffectBlur(blurStyle: .systemMaterial)
                (colorScheme == .light ? Color.black : Color.white).mask(ProgressView())
            }
        } else {
            Group {
                switch contentPanel.contentType {
                case .text: TitlePanelView(contentPanel: contentPanel)
                case .remoteImage, .image: ImagePanelView(contentPanel: $contentPanel)
                case .remoteFeedList: FeedListView(contentPanel: $contentPanel)
                case .remoteFeedGrid: FeedGridView(contentPanel: $contentPanel)
                case .link: LinkView(contentPanel: contentPanel)
                case .solidColor: SolidColorView(contentPanel: contentPanel)
                case .gradient: GradientView(contentPanel: contentPanel)
                default: EmptyView()
                }
            }
            .wrapInLink(destination: URL(string: contentPanel.linkURLString))
        }
    }
}

struct TitlePanelView: View {
    let contentPanel: ContentPanelModel
    @Environment(\.widgetColorScheme) var colorScheme

    var body: some View {
        Text(contentPanel.titleText)
            .textCaseMode(contentPanel.titleFont.textCaseMode)
            .font(contentPanel.titleFont.font)
            .foregroundColor(Color(contentPanel.foregroundColor.uiColor(for: colorScheme)))
    }
}

struct ImagePanelView: View {
    @Binding var contentPanel: ContentPanelModel
    @Environment(\.insideWidget) var insideWidget
    @Environment(\.widgetColorScheme) var colorScheme

    var body: some View {
        if let uiImage = ImageCache.shared.image(for: contentPanel.image.identifier(for: colorScheme), usePrebaked: insideWidget)
        {
            switch contentPanel.imageResizingMode {
            case .scaleToFit: Image(uiImage: uiImage).resizable().scaledToFit()
            case .scaleToFill: Image(uiImage: uiImage).resizable().scaledToFill()
            case .stretch: Image(uiImage: uiImage).resizable().frame(maxWidth: .infinity, maxHeight: .infinity)
            default: Image(uiImage: uiImage)
            }
        }
    }
}

struct LinkView: View {
    let contentPanel: ContentPanelModel

    var body: some View {
        let frame = contentPanel.frame.deviceRect
        ClearView().frame(width: frame.width, height: frame.height)
    }
}

struct SolidColorView: View {
    let contentPanel: ContentPanelModel
    @Environment(\.widgetColorScheme) var colorScheme

    var body: some View {
        Color(contentPanel.solidColor.uiColor(for: colorScheme))
    }
}

struct GradientView: View {
    let contentPanel: ContentPanelModel
    @Environment(\.widgetColorScheme) var colorScheme

    var startPoint: UnitPoint {
        let cosTheta = cos(contentPanel.gradientAngle)
        let sinTheta = sin(contentPanel.gradientAngle)
        let length = min(1 / abs(cosTheta), 1 / abs(sinTheta))
        let unitSquareX = cosTheta * length
        let unitSquareY = sinTheta * length

        return UnitPoint(x: unitSquareX * 0.5 + 0.5, y: 1 - (unitSquareY * 0.5 + 0.5))
    }

    var endPoint: UnitPoint {
        let opposite = startPoint

        return UnitPoint(x: 1 - opposite.x, y: 1 - opposite.y)
    }

    var body: some View {
        let startColor = Color(contentPanel.gradientColor1.uiColor(for: colorScheme))
        let endColor = Color(contentPanel.gradientColor2.uiColor(for: colorScheme))

        LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: startPoint, endPoint: endPoint)
    }
}

struct FeedListView: View {
    @Binding var contentPanel: ContentPanelModel

    @State var rowHeights: [Int: CGFloat] = [:]

    @Environment(\.insideWidget) var insideWidget
    @Environment(\.widgetColorScheme) var colorScheme

    func rowHeight(_ rowIndex: Int) -> CGFloat {
        guard let rowHeight = rowHeights[rowIndex] else { return 30 }

        return rowHeight
    }

    func heightThrough(endIndex: Int) -> CGFloat {
        var height: CGFloat = -contentPanel.contentSpacing

        for rowIndex in contentPanel.contentItemOffset ... endIndex {
            height += rowHeight(rowIndex) + contentPanel.contentSpacing
        }

        return max(height, 0)
    }

    var visibleHeight: CGFloat {
        var height: CGFloat = -contentPanel.contentSpacing

        for rowIndex in contentPanel.contentItemOffset ..< maxIndex {
            if height + rowHeight(rowIndex) >= contentPanel.frame.deviceRect.height { break }

            height += rowHeight(rowIndex) + contentPanel.contentSpacing // (rowIndex != contentPanel.contentItemOffset ? contentPanel.contentSpacing : 0)
        }

        return max(height, 0)
    }

    var maxIndex: Int {
        min(contentPanel.contentItemOffset + 10, contentPanel.contentItems.count)
    }

    @ViewBuilder
    func itemContent(rowIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: contentPanel.contentSpacing / 2) {
            Text(contentPanel.contentItems[rowIndex].title)
                .textCaseMode(contentPanel.titleFont.textCaseMode)
                .font(contentPanel.titleFont.font)
                .lineLimit(contentPanel.titleNumberOfLines)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(contentPanel.contentSpacing / 4)

            if contentPanel.bodyNumberOfLines > 0 && contentPanel.contentItems[rowIndex].body.count > 0
            {
                Text(contentPanel.contentItems[rowIndex].body)
                    .textCaseMode(contentPanel.bodyFont.textCaseMode)
                    .font(contentPanel.bodyFont.font)
                    .lineLimit(contentPanel.bodyNumberOfLines)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(contentPanel.contentSpacing / 4)
            }
        }
        .foregroundColor(Color(contentPanel.foregroundColor.uiColor(for: colorScheme)))
        .wrapInLink(destination: contentPanel.contentItems[rowIndex].linkURL, shouldWrap: insideWidget)
    }

    var body: some View {
        ZStack {
            ForEach(min(contentPanel.contentItemOffset, maxIndex) ..< maxIndex, id: \.self) {
                rowIndex in

                itemContent(rowIndex: rowIndex)
                    .measureHeight(coordinateSpace: contentPanel.id)
                    .frame(width: contentPanel.frame.deviceRect.width, height: rowHeight(rowIndex), alignment: .leading)
                    .position(x: contentPanel.frame.deviceRect.width / 2, y: heightThrough(endIndex: rowIndex) - rowHeight(rowIndex) / 2)
                    .opacity(rowIndex < maxIndex && heightThrough(endIndex: rowIndex) < contentPanel.frame.deviceRect.height ? 1 : 0)
            }
        }
        .coordinateSpace(name: contentPanel.id)
        .onPreferenceChange(HeightPreferenceKey.self) {
            for (index, rowHeight) in zip(min(contentPanel.contentItemOffset, maxIndex) ..< maxIndex, $0)
            {
                rowHeights[index] = rowHeight
            }
        }
    }
}

struct WrapInLink: ViewModifier {
    let destination: URL?
    let shouldWrap: Bool

    func body(content: Content) -> some View {
        Group {
            if shouldWrap {
                if let destination = destination {
                    Link(destination: destination) {
                        content
                    }
                } else {
                    content
                }
            } else {
                content
            }
        }
    }
}

extension View {
    func wrapInLink(destination: URL?, shouldWrap: Bool = true) -> some View {
        return modifier(WrapInLink(destination: destination, shouldWrap: shouldWrap))
    }
}

struct FeedGridView: View {
    @Binding var contentPanel: ContentPanelModel

    var cellHeight: CGFloat { (contentPanel.frame.deviceRect.height - CGFloat(contentPanel.gridRows - 1) * contentPanel.contentSpacing) / CGFloat(contentPanel.gridRows) }
    var cellWidth: CGFloat { (contentPanel.frame.deviceRect.width - CGFloat(contentPanel.gridColumns - 1) * contentPanel.contentSpacing) / CGFloat(contentPanel.gridColumns) }

    @Environment(\.insideWidget) var insideWidget

    var body: some View {
        ZStack {
            ForEach(contentPanel.contentItems) {
                contentItem in

                let index = (contentPanel.contentItems.firstIndex(of: contentItem) ?? -1) - contentPanel.contentItemOffset

                let row = index / contentPanel.gridColumns
                let column = index % contentPanel.gridColumns

                if index >= 0, row < contentPanel.gridRows {
                    if
                        let imageURL = contentItem.imageURL,
                        let uiImage = ImageCache.shared.image(for: imageURL.absoluteString, usePrebaked: insideWidget)
                    {
                        Color.gray.opacity(0.2)
                            .overlay(Image(uiImage: uiImage).resizable().scaledToFill())
                            .clipShape(RoundedRectangle(cornerRadius: contentPanel.contentSpacing / 2, style: .continuous))
                            .wrapInLink(destination: contentItem.linkURL, shouldWrap: insideWidget)
                            .frame(width: cellWidth, height: cellHeight)
                            .position(x: CGFloat(column) * (cellWidth + contentPanel.contentSpacing) + cellWidth / 2, y: CGFloat(row) * (cellHeight + contentPanel.contentSpacing) + cellHeight / 2)
                    } else {
                        Color.gray.opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: contentPanel.contentSpacing / 2, style: .continuous))
                            .wrapInLink(destination: contentItem.linkURL, shouldWrap: insideWidget)
                            .frame(width: cellWidth, height: cellHeight)
                            .position(x: CGFloat(column) * (cellWidth + contentPanel.contentSpacing) + cellWidth / 2, y: CGFloat(row) * (cellHeight + contentPanel.contentSpacing) + cellHeight / 2)
                    }
                }
            }
        }
    }
}

extension View {
    func measureHeight(coordinateSpace _: AnyHashable) -> some View {
        background(
            GeometryReader {
                geometryProxy in Color.clear.preference(key: HeightPreferenceKey.self, value: [geometryProxy.size.height])
            }
        )
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
