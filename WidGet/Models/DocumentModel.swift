//
//  Widget.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/12/20.
//

import Foundation
import SwiftUI
import WidgetKit

struct DocumentModel: Codable, Equatable {
    var widgetIDs: [UUID]
    var deletedWidgetIDs: [UUID]
    var widgetsByID: [UUID: WidgetModel]
    var lastSaved: Date?

    mutating func addWidget(widgetSize: WidgetModel.Size) -> UUID {
        let widgetName = newWidgetName(widgetSize: widgetSize)

        let widget = WidgetModel(widgetSize: widgetSize, widgetName: widgetName)
        widgetsByID[widget.id] = widget
        widgetIDs.insert(widget.id, at: 0)

        return widget.id
    }

    mutating func deleteWidget(id widgetID: UUID) {
        WidgetCenter.shared.getCurrentConfigurations { dump($0) }

        deletedWidgetIDs.append(widgetID)
        widgetIDs.removeAll { $0 == widgetID }
    }

    var cacheFileURLs: Set<URL> {
        var cacheFileURLs: Set<URL> = []

        if
            let documentFileURL = DocumentModel.documentFileURL,
            let metadataFileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.suiteName)?.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
        {
            cacheFileURLs.insert(documentFileURL)
            cacheFileURLs.insert(metadataFileURL)
        }

        for widget in widgetsByID.values {
            cacheFileURLs.formUnion(widget.cacheFileURLs)
        }

        return cacheFileURLs
    }

    static func == (lhs: DocumentModel, rhs: DocumentModel) -> Bool {
        lhs.widgetIDs == rhs.widgetIDs &&
            lhs.widgetsByID == rhs.widgetsByID &&
            lhs.deletedWidgetIDs == rhs.deletedWidgetIDs
    }

    enum CodingKeys: String, CodingKey {
        case widgetIDs
        case deletedWidgetIDs
        case widgetsByID
        case lastSaved
    }

    init() {
        widgetIDs = []
        deletedWidgetIDs = []
        widgetsByID = [:]
        lastSaved = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        widgetIDs = try container.decode([UUID].self, forKey: .widgetIDs)
        deletedWidgetIDs = try container.decode([UUID].self, forKey: .deletedWidgetIDs)
        widgetsByID = (try? container.decode([UUID: WidgetModel].self, forKey: .widgetsByID)) ?? [:] // Left for beta compatibility
        lastSaved = try container.decode(Date.self, forKey: .lastSaved)

        print("DocumentModel decoded widgetIDs \(widgetIDs)")
        print("DocumentModel decoded deletedWidgetIDs \(deletedWidgetIDs)")

        var fileWidgetsByID: [UUID: WidgetModel] = [:]

        for widgetID in widgetIDs + deletedWidgetIDs {
            if let widget = WidgetModel.load(widgetID: widgetID) {
                print("DocumentModel widget found for widgetID \(widgetID): \(widget.id)")
                fileWidgetsByID[widget.id] = widget
            } else {
                print("DocumentModel widget NOT found for widgetID \(widgetID)")
            }
        }

        widgetsByID.merge(fileWidgetsByID) { _, new in new }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(widgetIDs, forKey: .widgetIDs)
        try container.encode(deletedWidgetIDs, forKey: .deletedWidgetIDs)

        print("DocumentModel encoded widgetIDs \(widgetIDs)")
        print("DocumentModel encoded deletedWidgetIDs \(deletedWidgetIDs)")

        try container.encode(lastSaved, forKey: .lastSaved)
    }

    static var documentFileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.suiteName)?.appendingPathComponent("widget.json")
    }

    static func load() -> DocumentModel {
        do {
            if let url = documentFileURL {
                let documentData = try Data(contentsOf: url)
                let document = (try JSONDecoder().decode(DocumentModel.self, from: documentData))

                return document
            } else {
                print("URL failed")
            }
        } catch {
            dump(error)
        }

        return DocumentModel()
    }

    mutating func save() {
        lastSaved = Date()

        do {
            let documentData = try JSONEncoder().encode(self)

            print("~~~~ Saving document: \(documentData.count) bytes")

            if let url = DocumentModel.documentFileURL {
                try documentData.write(to: url, options: .atomicWrite)

                for var widget in widgetsByID.values {
                    widget.save()
                }
            } else {
                print("URL failed")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension DocumentModel {
    func newWidgetName(widgetSize: WidgetModel.Size) -> String {
        var widgetName: String

        switch widgetSize {
        case .large: widgetName = "Large Widget"
        case .medium: widgetName = "Medium Widget"
        case .small: widgetName = "Small Widget"
        }

        var suffix = 1

        while nameCollisionCount(widgetName: widgetName, suffix: suffix) > 0 {
            suffix += 1
        }

        return nameWithSuffix(widgetName: widgetName, suffix: suffix)
    }

    func nameCollisionCount(widgetName: String, suffix: Int) -> Int {
        widgetsByID.values.filter { $0.widgetName == nameWithSuffix(widgetName: widgetName, suffix: suffix) }.count
    }

    func nameWithSuffix(widgetName: String, suffix: Int) -> String {
        (suffix <= 1) ? widgetName : widgetName + " \(suffix)"
    }

    func linkDescription(for url: URL) -> String? {
        return widgetIDs.compactMap { widgetsByID[$0]?.linkDescription(for: url) }.first
    }
}
