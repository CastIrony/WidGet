//
//  WidgetModel.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/23/20.
//

import DominantColor
import Foundation
import SwiftUI
import WidgetKit

struct WidgetModel: Identifiable, Codable, Equatable {
    var id = UUID()
    var widgetSize: Size
    var widgetName: String
    var backgroundColor = ContentPanelModel.ColorModel(lightColor: HSBColor(uiColor: .white), darkColor: HSBColor(uiColor: .black), enableDarkColor: true)
    var lastSaved: Date? = nil

    var contentPanelIDs: [UUID] = []
    var deletedContentPanelIDs: [UUID] = []

    var contentPanelsByID: [UUID: ContentPanelModel] = [:]

    init(widgetSize: Size, widgetName: String) {
        id = UUID()
        self.widgetSize = widgetSize
        self.widgetName = widgetName
        backgroundColor = ContentPanelModel.ColorModel(lightColor: HSBColor(uiColor: .white), darkColor: HSBColor(uiColor: .black), enableDarkColor: true)
        contentPanelIDs = []
        deletedContentPanelIDs = []
        contentPanelsByID = [:]
    }

    enum CodingKeys: String, CodingKey {
        case id
        case widgetSize
        case widgetName
        case backgroundColor
        case contentPanelIDs
        case deletedContentPanelIDs
        case contentPanelsByID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        widgetSize = try container.decode(Size.self, forKey: .widgetSize)
        widgetName = try container.decode(String.self, forKey: .widgetName)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        backgroundColor = (try? container.decode(ContentPanelModel.ColorModel.self, forKey: .backgroundColor)) ?? ContentPanelModel.ColorModel(lightColor: HSBColor(uiColor: .white), darkColor: HSBColor(uiColor: .black), enableDarkColor: true)
        contentPanelIDs = (try? container.decode([UUID].self, forKey: .contentPanelIDs)) ?? []
        deletedContentPanelIDs = (try? container.decode([UUID].self, forKey: .deletedContentPanelIDs)) ?? []
        contentPanelsByID = (try? container.decode([UUID: ContentPanelModel].self, forKey: .contentPanelsByID)) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(widgetSize, forKey: .widgetSize)
        try container.encode(widgetName, forKey: .widgetName)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(id, forKey: .id)
        try container.encode(contentPanelIDs, forKey: .contentPanelIDs)
        try container.encode(deletedContentPanelIDs, forKey: .deletedContentPanelIDs)
        try container.encode(contentPanelsByID, forKey: .contentPanelsByID)
    }

    static func widgetFileURL(widgetID: UUID) -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.suiteName)?.appendingPathComponent("WidgetModel-\(widgetID).json")
    }

    static func load(widgetID: UUID) -> WidgetModel? {
        do {
            if let url = widgetFileURL(widgetID: widgetID) {
                let widgetData = try Data(contentsOf: url)
                let widget = (try JSONDecoder().decode(WidgetModel.self, from: widgetData))

                return widget
            } else {
                print("URL failed")
            }
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    mutating func save() {
        lastSaved = Date()

        do {
            let widgetData = try JSONEncoder().encode(self)

            print("~~~~ Saving widget: \(widgetData.count) bytes")

            if let url = WidgetModel.widgetFileURL(widgetID: id) {
                try widgetData.write(to: url, options: .atomicWrite)
            } else {
                print("URL failed")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension WidgetModel {
    var defaultContentFrame: ContentPanelModel.FrameModel {
        let widgetRect = CGRect(origin: CGPoint.zero, size: self.widgetSize.deviceFrame)
        let contentPanelRect = widgetRect.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return ContentPanelModel.FrameModel(deviceRect: contentPanelRect)
    }

    mutating func addContentPanel(contentType: ContentPanelModel.ContentType, paste: Bool = false) -> UUID
    {
        var contentPanel = ContentPanelModel(frame: defaultContentFrame, contentType: contentType)

        if paste {
            switch contentType {
            case .image:
                if
                    let pickedImage = UIPasteboard.general.image?.fixedOrientation()?.thumbnail(maxThumbnailSize: CGSize(width: 800, height: 800)),
                    let imageData = pickedImage.pngData()
                {
                    let imageIdentifier = String(describing: UUID())

                    print("storeImageData \(pickedImage) \(pickedImage.scale) \(imageIdentifier)")

                    ImageCache.shared.storeImageData(imageData, for: imageIdentifier)

                    let oldCacheFileURLs = contentPanel.cacheFileURLs

                    contentPanel.image.setIdentifier(imageIdentifier, for: .light)

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

            case .text: contentPanel.titleText = UIPasteboard.general.string ?? ""
//                case .link: contentPanel.linkURLString = UIPasteboard.general.string ?? ""
            case .remoteResource:
                contentPanel.targetURLString = UIPasteboard.general.string ?? ""
                switch widgetSize {
                case .small: contentPanel.gridColumns = 1; contentPanel.gridRows = 1
                case .medium: contentPanel.gridColumns = 2; contentPanel.gridRows = 2
                case .large: contentPanel.gridColumns = 3; contentPanel.gridRows = 5
                }
            default: break
            }
        }

        contentPanelsByID[contentPanel.id] = contentPanel
        contentPanelIDs.insert(contentPanel.id, at: 0)

        return contentPanel.id
    }

    mutating func deleteContentPanel(_ contentPanelID: UUID) {
        deletedContentPanelIDs.append(contentPanelID)
        contentPanelIDs.removeAll { $0 == contentPanelID }
    }

    mutating func duplicateContentPanel(_ contentPanel: ContentPanelModel) -> UUID {
        var newContentPanel = contentPanel

        newContentPanel.id = UUID()

        contentPanelIDs.insert(newContentPanel.id, at: 0)
        contentPanelsByID[newContentPanel.id] = newContentPanel

        return newContentPanel.id
    }

    enum Size: String, Codable {
        case small
        case medium
        case large

        var deviceFrame: CGSize {
            switch self {
            case .small:
                switch UIScreen.main.bounds.size {
                case CGSize(width: 320, height: 568): return CGSize(width: 141, height: 141)
                case CGSize(width: 375, height: 667): return CGSize(width: 148, height: 148)
                case CGSize(width: 375, height: 812): return CGSize(width: 155, height: 155)
                case CGSize(width: 390, height: 844): return CGSize(width: 158, height: 158)
                case CGSize(width: 414, height: 736): return CGSize(width: 157, height: 157)
                case CGSize(width: 414, height: 896): return CGSize(width: 169, height: 169)
                case CGSize(width: 428, height: 926): return CGSize(width: 170, height: 170)

                case CGSize(width: 768, height: 1024): return CGSize(width: 155, height: 155)
                case CGSize(width: 810, height: 1080): return CGSize(width: 155, height: 155)
                case CGSize(width: 820, height: 1180): return CGSize(width: 155, height: 155)
                case CGSize(width: 834, height: 1194): return CGSize(width: 155, height: 155)
                case CGSize(width: 1024, height: 1366): return CGSize(width: 170, height: 170)

                default: return CGSize(width: 150, height: 150)
                }
            case .medium:
                switch UIScreen.main.bounds.size {
                case CGSize(width: 320, height: 568): return CGSize(width: 292, height: 141)
                case CGSize(width: 375, height: 667): return CGSize(width: 321, height: 148)
                case CGSize(width: 375, height: 812): return CGSize(width: 329, height: 155)
                case CGSize(width: 390, height: 844): return CGSize(width: 338, height: 158)
                case CGSize(width: 414, height: 736): return CGSize(width: 348, height: 157)
                case CGSize(width: 414, height: 896): return CGSize(width: 360, height: 169)
                case CGSize(width: 428, height: 926): return CGSize(width: 364, height: 170)

                case CGSize(width: 768, height: 1024): return CGSize(width: 329, height: 155)
                case CGSize(width: 810, height: 1080): return CGSize(width: 329, height: 155)
                case CGSize(width: 820, height: 1180): return CGSize(width: 329, height: 155)
                case CGSize(width: 834, height: 1194): return CGSize(width: 329, height: 155)
                case CGSize(width: 1024, height: 1366): return CGSize(width: 364, height: 170)

                default: return CGSize(width: 300, height: 150)
                }
            case .large:
                switch UIScreen.main.bounds.size {
                case CGSize(width: 320, height: 568): return CGSize(width: 292, height: 311)
                case CGSize(width: 375, height: 667): return CGSize(width: 321, height: 324)
                case CGSize(width: 375, height: 812): return CGSize(width: 329, height: 345)
                case CGSize(width: 390, height: 844): return CGSize(width: 338, height: 354)
                case CGSize(width: 414, height: 736): return CGSize(width: 348, height: 351)
                case CGSize(width: 414, height: 896): return CGSize(width: 360, height: 379)
                case CGSize(width: 428, height: 926): return CGSize(width: 364, height: 382)

                case CGSize(width: 768, height: 1024): return CGSize(width: 329, height: 345)
                case CGSize(width: 810, height: 1080): return CGSize(width: 329, height: 345)
                case CGSize(width: 820, height: 1180): return CGSize(width: 329, height: 345)
                case CGSize(width: 834, height: 1194): return CGSize(width: 329, height: 345)
                case CGSize(width: 1024, height: 1366): return CGSize(width: 364, height: 382)

                default: return CGSize(width: 300, height: 300)
                }
            }
        }
    }

    var mainLinkURL: URL? {
        return contentPanelIDs.reversed().compactMap { contentPanelsByID[$0]?.mainLinkURL }.first
    }

    var lastRefresh: Date? {
        var latestDate: Date?

        for contentPanelID in contentPanelIDs {
            if let lastRefresh = contentPanelsByID[contentPanelID]?.lastRefresh {
                if latestDate == nil || latestDate! < lastRefresh {
                    latestDate = lastRefresh
                }
            }
        }

        return latestDate
    }

    var priorityScore: Int {
        guard let lastRefresh = lastRefresh else { return 0 }
        return max(1000 - Int(Date().timeIntervalSince(lastRefresh)), 0)
    }

    func linkDescription(for url: URL) -> String? {
        return contentPanelIDs.compactMap { contentPanelsByID[$0]?.linkDescription(for: url) }.first
    }

    func widgetColors() -> [HSBColor] {
        return contentPanelIDs.flatMap { contentPanelsByID[$0]?.panelColors ?? [] }.unique()
    }

    func widgetColors(exceptFor contentPanelID: UUID) -> [HSBColor] {
        return contentPanelIDs.flatMap { $0 == contentPanelID ? [] : contentPanelsByID[$0]?.panelColors ?? [] }.unique()
    }

    var cornerRadius: CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width

        return 0.053 * screenWidth
    }

    func cornerRadius(for contentPanelID: UUID) -> CGFloat {
        let deviceFrame = widgetSize.deviceFrame

        guard
            let contentPanel = contentPanelsByID[contentPanelID],
            !contentPanel.frame.isCloseToContainer(size: deviceFrame),
            contentPanel.contentType != .remoteFeedList,
            contentPanel.contentType != .text
        else { return 0 }

        let contentPanelRect = contentPanel.frame.deviceRect
        let left = contentPanelRect.minX
        let top = contentPanelRect.minY
        let right = deviceFrame.width - contentPanelRect.maxX
        let bottom = deviceFrame.height - contentPanelRect.maxY

        return max(cornerRadius - max(min(min(min(left, top), right), bottom), 0), 0)
    }

    var cacheFileURLs: Set<URL> {
        var cacheFileURLs: Set<URL> = []

        if let widgetFileURL = WidgetModel.widgetFileURL(widgetID: id) {
            cacheFileURLs.insert(widgetFileURL)
        }

        for contentPanel in contentPanelsByID.values {
            cacheFileURLs.formUnion(contentPanel.cacheFileURLs)
        }

        return cacheFileURLs
    }

    mutating func bakeThumbnails(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        for contentPanelID in contentPanelIDs {
            dispatchGroup.enter()
            contentPanelsByID[contentPanelID]?.bakeThumbnails {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
