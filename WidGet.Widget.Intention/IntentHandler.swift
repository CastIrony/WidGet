//
//  IntentHandler.swift
//  WidGet.Widget.Intention
//
//  Created by Bernstein, Joel on 7/22/20.
//

import Intents

class IntentHandler: INExtension, ConfigurationSmallIntentHandling, ConfigurationMediumIntentHandling, ConfigurationLargeIntentHandling {
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        return dateFormatter
    }

    func provideUserWidgetOptionsCollection(for intent: ConfigurationSmallIntent, with completion: @escaping (INObjectCollection<UserWidget>?, Error?) -> Void)
    {
        let document = DocumentModel.load()

        var results: [UserWidget] = [defaultUserWidget(for: intent)!]

        for widgetID in document.widgetIDs {
            guard let widget = document.widgetsByID[widgetID] else { continue }

            if widget.widgetSize == .small {
                let userWidget = UserWidget(identifier: String(describing: widget.id), display: widget.widgetName)
                results.append(userWidget)
            }
        }

        completion(INObjectCollection(items: results), nil)
    }

    func provideUserWidgetOptionsCollection(for intent: ConfigurationMediumIntent, with completion: @escaping (INObjectCollection<UserWidget>?, Error?) -> Void)
    {
        let document = DocumentModel.load()
        var results: [UserWidget] = [defaultUserWidget(for: intent)!]

        for widgetID in document.widgetIDs {
            guard let widget = document.widgetsByID[widgetID] else { continue }

            if widget.widgetSize == .medium {
                let userWidget = UserWidget(identifier: String(describing: widget.id), display: widget.widgetName)
                results.append(userWidget)
            }
        }

        completion(INObjectCollection(items: results), nil)
    }

    func provideUserWidgetOptionsCollection(for intent: ConfigurationLargeIntent, with completion: @escaping (INObjectCollection<UserWidget>?, Error?) -> Void)
    {
        let document = DocumentModel.load()
        var results: [UserWidget] = [defaultUserWidget(for: intent)!]

        for widgetID in document.widgetIDs {
            guard let widget = document.widgetsByID[widgetID] else { continue }

            if widget.widgetSize == .large {
                let userWidget = UserWidget(identifier: String(describing: widget.id), display: widget.widgetName)
                results.append(userWidget)
            }
        }

        completion(INObjectCollection(items: results), nil)
    }

    func defaultUserWidget(for _: ConfigurationSmallIntent) -> UserWidget? {
        UserWidget(identifier: "foo", display: "WID:GET")
    }

    func defaultUserWidget(for _: ConfigurationMediumIntent) -> UserWidget? {
        UserWidget(identifier: "foo", display: "WID:GET")
    }

    func defaultUserWidget(for _: ConfigurationLargeIntent) -> UserWidget? {
        UserWidget(identifier: "foo", display: "WID:GET")
    }

    override func handler(for _: INIntent) -> Any {
        return self
    }
}
