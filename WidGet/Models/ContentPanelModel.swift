//
//  ContentPanelModel.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/23/20.
//

import Foundation
import SwiftUI
import UIKit

struct ContentPanelModel: Identifiable, Codable, Equatable {
    var id = UUID()

    var frame: FrameModel
    var contentType: ContentType

    var titleText: String = "Text"
    var linkURLString: String = ""

    var targetURLString: String = ""
    var resourceURL: URL? = nil
    var refreshInterval = ContentRefreshInterval.halfHour
    var lastRefresh: Date? = nil
    var errorString: String? = nil

    var contentItems: [ItemModel] = []
    var contentItemOffset: Int = 0

    var image = ImageModel(lightIdentifier: nil, darkIdentifier: nil, enableDarkIdentifier: false)
    var imageResizingMode = ImageResizingMode.scaleToFill
    var dominantImageColors: [HSBColor] = []

    var contentAlignment = ContentAlignment.center
    var contentSpacing: CGFloat = 8

    var titleFont = FontModel(familyName: "System", fontName: "System Semibold", size: 15, textCaseMode: .normal, smallCapsMode: .normal)
    var titleNumberOfLines: Int = 2

    var bodyFont = FontModel(familyName: "System", fontName: "System Regular", size: 12, textCaseMode: .normal, smallCapsMode: .normal)
    var bodyNumberOfLines: Int = 2

    var foregroundColor = ColorModel(lightColor: HSBColor(hue: 0, saturation: 0, brightness: 0, alpha: 1), darkColor: HSBColor(hue: 0, saturation: 0, brightness: 1, alpha: 1))
    var solidColor = ColorModel(lightColor: RGBColor(red: 175 / 255, green: 82 / 255, blue: 222 / 255, alpha: 1).hsb, darkColor: RGBColor(red: 191 / 255, green: 90 / 255, blue: 242 / 255, alpha: 1).hsb)
    var gradientColor1 = ColorModel(lightColor: RGBColor(red: 255 / 255, green: 45 / 255, blue: 85 / 255, alpha: 1).hsb, darkColor: RGBColor(red: 255 / 255, green: 55 / 255, blue: 95 / 255, alpha: 1).hsb)
    var gradientColor2 = ColorModel(lightColor: RGBColor(red: 255 / 255, green: 204 / 255, blue: 0 / 255, alpha: 1).hsb, darkColor: RGBColor(red: 255 / 255, green: 214 / 255, blue: 10 / 255, alpha: 1).hsb)

    var blendMode: BlendMode = .normal

    var gradientAngle: CGFloat = 0

    var gridRows: Int = 5
    var gridColumns: Int = 3
    var gridTitlePosition: GridTitlePosition = .hidden

    enum CodingKeys: String, CodingKey {
        case id
        case frame
        case contentType
        case titleText
        case linkURLString
        case targetURLString
        case resourceURL
        case refreshInterval
        case lastRefresh
        case errorString
        case contentItems
        case contentItemOffset
        case image
        case imageResizingMode
        case dominantImageColors
        case contentAlignment
        case contentSpacing
        case titleFont
        case titleNumberOfLines
        case bodyFont
        case bodyNumberOfLines
        case foregroundColor
        case solidColor
        case gradientColor1
        case gradientColor2
        case blendMode
        case gradientAngle
        case gridRows
        case gridColumns
        case gridTitlePosition
    }

    init(frame: FrameModel, contentType: ContentType) {
        self.frame = frame
        self.contentType = contentType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        frame = try container.decode(FrameModel.self, forKey: .frame)
        contentType = try container.decode(ContentType.self, forKey: .contentType)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        titleText = (try? container.decode(String.self, forKey: .titleText)) ?? ""
        linkURLString = (try? container.decode(String.self, forKey: .linkURLString)) ?? ""
        targetURLString = (try? container.decode(String.self, forKey: .targetURLString)) ?? ""
        resourceURL = (try? container.decode(URL.self, forKey: .resourceURL)) ?? nil
        refreshInterval = (try? container.decode(ContentRefreshInterval.self, forKey: .refreshInterval)) ?? ContentRefreshInterval.halfHour
        lastRefresh = (try? container.decode(Date.self, forKey: .lastRefresh)) ?? nil
        errorString = (try? container.decode(String.self, forKey: .errorString)) ?? nil
        contentItems = (try? container.decode([ItemModel].self, forKey: .contentItems)) ?? []
        contentItemOffset = (try? container.decode(Int.self, forKey: .contentItemOffset)) ?? 0
        image = (try? container.decode(ImageModel.self, forKey: .image)) ?? ImageModel(lightIdentifier: nil, darkIdentifier: nil, enableDarkIdentifier: false)
        imageResizingMode = (try? container.decode(ImageResizingMode.self, forKey: .imageResizingMode)) ?? ImageResizingMode.scaleToFill
        dominantImageColors = (try? container.decode([HSBColor].self, forKey: .dominantImageColors)) ?? []
        contentAlignment = (try? container.decode(ContentAlignment.self, forKey: .contentAlignment)) ?? ContentAlignment.center
        contentSpacing = (try? container.decode(CGFloat.self, forKey: .contentSpacing)) ?? 8
        titleFont = (try? container.decode(FontModel.self, forKey: .titleFont)) ?? FontModel(familyName: "System", fontName: "System Semibold", size: 15, textCaseMode: .normal, smallCapsMode: .normal)
        titleNumberOfLines = (try? container.decode(Int.self, forKey: .titleNumberOfLines)) ?? 2
        bodyFont = (try? container.decode(FontModel.self, forKey: .bodyFont)) ?? FontModel(familyName: "System", fontName: "System Regular", size: 12, textCaseMode: .normal, smallCapsMode: .normal)
        bodyNumberOfLines = (try? container.decode(Int.self, forKey: .bodyNumberOfLines)) ?? 2
        foregroundColor = (try? container.decode(ColorModel.self, forKey: .foregroundColor)) ?? ColorModel(lightColor: HSBColor(hue: 0, saturation: 0, brightness: 0, alpha: 1), darkColor: HSBColor(hue: 0, saturation: 0, brightness: 1, alpha: 1))
        solidColor = (try? container.decode(ColorModel.self, forKey: .solidColor)) ?? ColorModel(lightColor: RGBColor(red: 175 / 255, green: 82 / 255, blue: 222 / 255, alpha: 1).hsb, darkColor: RGBColor(red: 191 / 255, green: 90 / 255, blue: 242 / 255, alpha: 1).hsb)
        gradientColor1 = (try? container.decode(ColorModel.self, forKey: .gradientColor1)) ?? ColorModel(lightColor: RGBColor(red: 255 / 255, green: 45 / 255, blue: 85 / 255, alpha: 1).hsb, darkColor: RGBColor(red: 255 / 255, green: 55 / 255, blue: 95 / 255, alpha: 1).hsb)
        gradientColor2 = (try? container.decode(ColorModel.self, forKey: .gradientColor2)) ?? ColorModel(lightColor: RGBColor(red: 255 / 255, green: 204 / 255, blue: 0 / 255, alpha: 1).hsb, darkColor: RGBColor(red: 255 / 255, green: 214 / 255, blue: 10 / 255, alpha: 1).hsb)
        blendMode = (try? container.decode(BlendMode.self, forKey: .blendMode)) ?? .normal
        gradientAngle = (try? container.decode(CGFloat.self, forKey: .gradientAngle)) ?? 0
        gridRows = (try? container.decode(Int.self, forKey: .gridRows)) ?? 5
        gridColumns = (try? container.decode(Int.self, forKey: .gridColumns)) ?? 3
        gridTitlePosition = (try? container.decode(GridTitlePosition.self, forKey: .gridTitlePosition)) ?? .hidden
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frame, forKey: .frame)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(id, forKey: .id)
        try container.encode(titleText, forKey: .titleText)
        try container.encode(linkURLString, forKey: .linkURLString)
        try container.encode(targetURLString, forKey: .targetURLString)
        try container.encode(resourceURL, forKey: .resourceURL)
        try container.encode(refreshInterval, forKey: .refreshInterval)
        try container.encode(lastRefresh, forKey: .lastRefresh)
        try container.encode(errorString, forKey: .errorString)
        try container.encode(contentItems, forKey: .contentItems)
        try container.encode(contentItemOffset, forKey: .contentItemOffset)
        try container.encode(image, forKey: .image)
        try container.encode(imageResizingMode, forKey: .imageResizingMode)
        try container.encode(dominantImageColors, forKey: .dominantImageColors)
        try container.encode(contentAlignment, forKey: .contentAlignment)
        try container.encode(contentSpacing, forKey: .contentSpacing)
        try container.encode(titleFont, forKey: .titleFont)
        try container.encode(titleNumberOfLines, forKey: .titleNumberOfLines)
        try container.encode(bodyFont, forKey: .bodyFont)
        try container.encode(bodyNumberOfLines, forKey: .bodyNumberOfLines)
        try container.encode(foregroundColor, forKey: .foregroundColor)
        try container.encode(solidColor, forKey: .solidColor)
        try container.encode(gradientColor1, forKey: .gradientColor1)
        try container.encode(gradientColor2, forKey: .gradientColor2)
        try container.encode(blendMode, forKey: .blendMode)
        try container.encode(gradientAngle, forKey: .gradientAngle)
        try container.encode(gridRows, forKey: .gridRows)
        try container.encode(gridColumns, forKey: .gridColumns)
        try container.encode(gridTitlePosition, forKey: .gridTitlePosition)
    }
}

extension ContentPanelModel {
    var mainLinkURL: URL? {
        if contentItems.count > 0 {
            let end = contentItems.count - 1
            let start = min(contentItemOffset, end)

            return contentItems[start ... end].compactMap { $0.linkURL }.first ?? URL(string: linkURLString)
        }

        return URL(string: linkURLString)
    }

    func linkDescription(for url: URL) -> String? {
        return contentItems.compactMap { $0.linkURL == url ? $0.title : nil }.first
    }

    var panelColors: [HSBColor] {
        var colors: [HSBColor] = dominantImageColors

        switch contentType {
        case .gradient: colors.append(contentsOf: [gradientColor1.lightColor, gradientColor2.lightColor])
        case .solidColor: colors.append(contentsOf: [solidColor.lightColor])
        case .text, .remoteFeedList, .remoteCalendar, .remoteFeedGrid: colors.append(contentsOf: [foregroundColor.lightColor])
        default: break
        }

        return colors
    }

    enum ContentType: String, Codable, Equatable {
        case text
        case image
        case link
        case solidColor
        case gradient
        case remoteResource
        case remoteImage
        case remoteFeedList
        case remoteFeedGrid
        case remoteCalendar

        static let remoteContentTypes: Set<ContentType> = [.remoteResource, .remoteImage, .remoteFeedList, .remoteFeedGrid, .remoteCalendar]
        static let remoteFeedTypes: Set<ContentType> = [.remoteFeedList, .remoteFeedGrid]
        static let imageTypes: Set<ContentType> = [.image, .remoteImage]

        var isRemoteContentType: Bool { ContentType.remoteContentTypes.contains(self) }
        var isRemoteFeedType: Bool { ContentType.remoteFeedTypes.contains(self) }
        var isImageType: Bool { ContentType.imageTypes.contains(self) }
    }

    var cacheFileURLs: Set<URL> {
        var cacheFileURLs: Set<URL> = []

        if let identifier = image.lightIdentifier {
            if let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: false) { cacheFileURLs.insert(cacheFileURL) }
            if let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: true) { cacheFileURLs.insert(cacheFileURL) }
        }

        if image.enableDarkIdentifier, let identifier = image.darkIdentifier {
            if let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: false) { cacheFileURLs.insert(cacheFileURL) }
            if let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: true) { cacheFileURLs.insert(cacheFileURL) }
        }

        for contentItem in contentItems {
            cacheFileURLs.formUnion(contentItem.cacheFileURLs)
        }

        return cacheFileURLs
    }

    func bakeThumbnails(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        if contentType.isImageType, let lightIdentifier = image.lightIdentifier, let darkIdentifier = image.darkIdentifier
        {
            dispatchGroup.enter()
            ImageCache.shared.bakeThumbnail(for: lightIdentifier, thumbnailSize: frame.deviceRect.size, sizingMode: imageResizingMode, contentAlignment: contentAlignment)
                {
                    dispatchGroup.leave()
                }

            dispatchGroup.enter()
            ImageCache.shared.bakeThumbnail(for: darkIdentifier, thumbnailSize: frame.deviceRect.size, sizingMode: imageResizingMode, contentAlignment: contentAlignment)
                {
                    dispatchGroup.leave()
                }
        } else if contentType == .remoteFeedGrid {
            var cellHeight: CGFloat { (frame.deviceRect.height - CGFloat(gridRows - 1) * contentSpacing) / CGFloat(gridRows) }
            var cellWidth: CGFloat { (frame.deviceRect.width - CGFloat(gridColumns - 1) * contentSpacing) / CGFloat(gridColumns) }

            for contentItem in contentItems {
                let index = (contentItems.firstIndex(of: contentItem) ?? -1) - contentItemOffset

                let row = index / gridColumns

                if index >= 0, row < gridRows {
                    if let imageURL = contentItem.imageURL {
                        dispatchGroup.enter()
                        ImageCache.shared.bakeThumbnail(for: imageURL.absoluteString, thumbnailSize: CGSize(width: cellWidth, height: cellHeight), sizingMode: imageResizingMode, contentAlignment: contentAlignment)
                            {
                                dispatchGroup.leave()
                            }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}

extension ContentPanelModel {
    struct ItemModel: Identifiable, Codable, Equatable {
        let id: UUID

        let title: String
        let body: String
        let date: Date?
        let linkURL: URL?
        let imageURL: URL?

        var imageData: Data? = nil

        init(id: UUID = UUID(), title: String, body: String, date: Date? = nil, linkURL: URL? = nil, imageURL: URL? = nil)
        {
            self.id = id
            self.title = title
            self.body = body
            self.date = date
            self.linkURL = linkURL
            self.imageURL = imageURL
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.title == rhs.title &&
                lhs.body == rhs.body &&
                lhs.date == rhs.date &&
                lhs.linkURL == rhs.linkURL &&
                lhs.imageURL == rhs.imageURL
        }

        var cacheFileURLs: Set<URL> {
            var cacheFileURLs: Set<URL> = []

            if let identifier = imageURL?.absoluteString {
                if let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: false) { cacheFileURLs.insert(cacheFileURL) }
                if let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: true) { cacheFileURLs.insert(cacheFileURL) }
            }

            return cacheFileURLs
        }
    }

    struct FrameModel: Codable, Equatable {
        var originX: CGFloat
        var originY: CGFloat

        var width: CGFloat
        var height: CGFloat

        var deviceRect: CGRect {
            let fullWidth = WidgetModel.Size.large.deviceFrame.width

            let rectWidth = width * fullWidth
            let rectHeight = height * fullWidth
            let rectOriginX = originX * fullWidth
            let rectOriginY = originY * fullWidth

            return CGRect(x: rectOriginX, y: rectOriginY, width: rectWidth, height: rectHeight)
        }

        init(originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat) {
            self.originX = originX
            self.originY = originY
            self.width = width
            self.height = height
        }

        init(deviceRect: CGRect) {
            let fullWidth = WidgetModel.Size.large.deviceFrame.width

            originX = deviceRect.origin.x / fullWidth
            originY = deviceRect.origin.y / fullWidth
            width = deviceRect.size.width / fullWidth
            height = deviceRect.size.height / fullWidth
        }

        func isCloseToContainer(size: CGSize) -> Bool {
            deviceRect.minX < 1 || deviceRect.minY < 1 || deviceRect.maxX > size.width - 1 || deviceRect.maxY > size.height - 1
        }
    }

    enum ImageResizingMode: String, Codable, Equatable {
        case fullSize
        case scaleToFit
        case scaleToFill
        case stretch
    }

    enum TextCaseMode: String, Codable, Equatable {
        case normal
        case uppercase
        case lowercase
    }

    enum SmallCapsMode: String, Codable, Equatable {
        case normal
        case lowercaseSmallCaps
        case smallCaps
    }

    enum BlendMode: String, CaseIterable, Codable, Equatable {
        case normal = "Normal"
        case multiply = "Multiply"
        case screen = "Screen"
        case overlay = "Overlay"
        case darken = "Darken"
        case lighten = "Lighten"
        case colorDodge = "Color Dodge"
        case colorBurn = "Color Burn"
        case softLight = "Soft Light"
        case hardLight = "Hard Light"
        case difference = "Difference"
        case exclusion = "Exclusion"
        case hue = "Hue"
        case saturation = "Saturation"
        case color = "Color"
        case luminosity = "Luminosity"
        case sourceAtop = "Source Atop"
        case destinationOver = "Destination Over"
        case destinationOut = "Destination Out"
        case plusDarker = "Plus Darker"
        case plusLighter = "Plus Lighter"

        var swiftUIBlendMode: SwiftUI.BlendMode {
            switch self {
            case .normal: return SwiftUI.BlendMode.normal
            case .multiply: return SwiftUI.BlendMode.multiply
            case .screen: return SwiftUI.BlendMode.screen
            case .overlay: return SwiftUI.BlendMode.overlay
            case .darken: return SwiftUI.BlendMode.darken
            case .lighten: return SwiftUI.BlendMode.lighten
            case .colorDodge: return SwiftUI.BlendMode.colorDodge
            case .colorBurn: return SwiftUI.BlendMode.colorBurn
            case .softLight: return SwiftUI.BlendMode.softLight
            case .hardLight: return SwiftUI.BlendMode.hardLight
            case .difference: return SwiftUI.BlendMode.difference
            case .exclusion: return SwiftUI.BlendMode.exclusion
            case .hue: return SwiftUI.BlendMode.hue
            case .saturation: return SwiftUI.BlendMode.saturation
            case .color: return SwiftUI.BlendMode.color
            case .luminosity: return SwiftUI.BlendMode.luminosity
            case .sourceAtop: return SwiftUI.BlendMode.sourceAtop
            case .destinationOver: return SwiftUI.BlendMode.destinationOver
            case .destinationOut: return SwiftUI.BlendMode.destinationOut
            case .plusDarker: return SwiftUI.BlendMode.plusDarker
            case .plusLighter: return SwiftUI.BlendMode.plusLighter
            }
        }
    }

    struct FontModel: Codable, Equatable {
        var familyName: String
        var fontName: String
        var size: CGFloat
        var textCaseMode: TextCaseMode
        var smallCapsMode: SmallCapsMode

        static var familyNames: [String] {
            ["System", "System Serif", "System Rounded", "System Mono"] + UIFont.familyNames
        }

        static func fontNames(forFamilyName familyName: String) -> [String] {
            if ["System", "System Serif", "System Rounded", "System Mono"].contains(familyName) {
                var fontNames: [String] = []
                var weights: [String]

                switch familyName {
                case "System Serif": weights = ["Regular", "Medium", "Semibold", "Bold", "Heavy", "Black"]
                case "System Mono": weights = ["Light", "Regular", "Medium", "Semibold", "Bold", "Heavy", "Black"]
                default: weights = ["Ultra Light", "Thin", "Light", "Regular", "Medium", "Semibold", "Bold", "Heavy", "Black"]
                }

                for weight in weights {
                    fontNames.append(familyName + " " + weight)

                    if ["System", "System Serif"].contains(familyName) {
                        fontNames.append(familyName + " " + weight + " Italic")
                    }
                }

                return fontNames
            } else {
                return UIFont.fontNames(forFamilyName: familyName)
            }
        }

        var font: Font {
            return self.font(size: size)
        }

        func font(size: CGFloat) -> Font {
            var font: Font

            if ["System", "System Serif", "System Rounded", "System Mono"].contains(familyName) {
                var italic = false
                var weightString = fontName

                if fontName.hasPrefix(familyName) {
                    weightString = String(weightString.suffix(weightString.count - (familyName.count + 1)))
                }

                if fontName.hasSuffix("Italic") {
                    italic = true
                    weightString = String(weightString.prefix(weightString.count - 7))
                }

                var weight: Font.Weight
                var design: Font.Design

                switch weightString {
                case "Ultra Light": weight = .ultraLight
                case "Thin": weight = .thin
                case "Light": weight = .light
                case "Medium": weight = .medium
                case "Semibold": weight = .semibold
                case "Bold": weight = .bold
                case "Heavy": weight = .heavy
                case "Black": weight = .black
                default: weight = .regular
                }

                switch familyName {
                case "System Serif": design = .serif
                case "System Rounded": design = .rounded
                case "System Mono": design = .monospaced
                default: design = .default
                }

                font = Font.system(size: size, weight: weight, design: design)

                if italic {
                    font = font.italic()
                }

                if smallCapsMode == .lowercaseSmallCaps {
                    font = font.lowercaseSmallCaps()
                } else if smallCapsMode == .smallCaps {
                    font = font.smallCaps()
                }
            } else {
                font = Font.custom(fontName, fixedSize: size)
            }

            return font
        }
    }

    struct ColorModel: Codable, Equatable {
        var lightColor: HSBColor
        var darkColor: HSBColor
        var enableDarkColor: Bool

        init(lightColor: HSBColor, darkColor: HSBColor, enableDarkColor: Bool = false) {
            self.lightColor = lightColor
            self.darkColor = darkColor
            self.enableDarkColor = enableDarkColor
        }

        func uiColor(for colorScheme: ColorScheme) -> UIColor {
            guard enableDarkColor else { return lightColor.uiColor }

            switch colorScheme {
            case .light: return lightColor.uiColor
            case .dark: return darkColor.uiColor
            @unknown default: return lightColor.uiColor
            }
        }

        enum CodingKeys: String, CodingKey {
            case lightColor
            case darkColor
            case enableDarkColor
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            lightColor = try container.decode(HSBColor.self, forKey: .lightColor)
            darkColor = try container.decode(HSBColor.self, forKey: .darkColor)
            enableDarkColor = (try? container.decode(Bool.self, forKey: .enableDarkColor)) ?? false
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(lightColor, forKey: .lightColor)
            try container.encode(darkColor, forKey: .darkColor)
            try container.encode(enableDarkColor, forKey: .enableDarkColor)
        }
    }

    struct ImageModel: Codable, Equatable {
        var lightIdentifier: String?
        var darkIdentifier: String?
        var enableDarkIdentifier: Bool

        func identifier(for colorScheme: ColorScheme) -> String? {
            guard enableDarkIdentifier else { return lightIdentifier }

            switch colorScheme {
            case .light: return lightIdentifier
            case .dark: return darkIdentifier
            @unknown default: return lightIdentifier
            }
        }

        mutating func setIdentifier(_ identifier: String?, for colorScheme: ColorScheme) {
            if !enableDarkIdentifier || colorScheme == .light {
                lightIdentifier = identifier
            }

            if !enableDarkIdentifier || colorScheme == .dark {
                darkIdentifier = identifier
            }
        }
    }

    enum AspectRatio: String, Codable, Equatable {
        case sixteenNine = "16:9"
        case fourThree = "4:3"
        case square = "Square"
        case threeFour = "3:4"
        case nineSixteen = "9:16"
        case freeform = "Freeform"
    }

    enum ContentRefreshInterval: TimeInterval, Codable, Equatable {
        case halfHour = 0
        case hour = 3600
        case sixHour = 21600
        case twelveHour = 43200
        case day = 86400
        case week = 604_800
        case never = 31_536_000
    }

    enum GridTitlePosition: String, Codable, Equatable {
        case hidden = "Hidden"
        case above = "Above"
        case below = "Below"
        case inside = "Inside"
    }

    enum ContentAlignment: String, Codable, Equatable {
        case center
        case leading
        case trailing
        case top
        case bottom
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing

        var alignment: Alignment {
            switch self {
            case .center: return .center
            case .leading: return .leading
            case .trailing: return .trailing
            case .top: return .top
            case .bottom: return .bottom
            case .topLeading: return .topLeading
            case .topTrailing: return .topTrailing
            case .bottomLeading: return .bottomLeading
            case .bottomTrailing: return .bottomTrailing
            }
        }
    }
}

extension Text {
    func textCaseMode(_ mode: ContentPanelModel.TextCaseMode) -> some View {
        applyIf(mode == .uppercase) { $0.textCase(.uppercase) }
            .applyIf(mode == .lowercase) { $0.textCase(.lowercase) }
    }
}
