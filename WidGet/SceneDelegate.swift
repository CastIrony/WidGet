//
//  SceneDelegate.swift
//  GetWid
//
//  Created by Bernstein, Joel on 7/2/20.
//

import SwiftUI
import UIKit
import WidgetKit

class AppOptions: ObservableObject {
    @Published var handlingLink = false
    @Published var linkDescription = ""
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let appOptions = AppOptions()

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let document = DocumentModel.load()

        if
            let url = URLContexts.first?.url,
            let hostName = url.host
        {
            UIApplication.shared.open(url)

            withAnimation(.none) {
                appOptions.linkDescription = document.linkDescription(for: url) ?? hostName
                appOptions.handlingLink = true
            }
        }
    }

//    var contentPanel1 = ContentPanelModel(contentType: .remoteFeedList, title: "Image Foo", frame: ContentPanelModel.FrameModel(originX: 0.1, originY: 0.1, width: 0.8, height: 0.8), resourceURL:URL(string: "https://rss.nytimes.com/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt/services/xml/rss/nyt"), automaticallyRefresh: true, lastRefresh: nil, errorString: nil)

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        let document = DocumentModel.load()

        if
            let url = connectionOptions.urlContexts.first?.url,
            let hostName = url.host
        {
            UIApplication.shared.open(url)
            withAnimation(.none) {
                appOptions.linkDescription = document.linkDescription(for: url) ?? hostName
                appOptions.handlingLink = true
            }
        } else if
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.suiteName),
            let filePaths = (try? FileManager.default.contentsOfDirectory(atPath: container.path))
        {
            Set(filePaths.compactMap { container.appendingPathComponent($0) }).subtracting(document.cacheFileURLs).forEach
                {
                    do {
                        try FileManager.default.removeItem(at: $0)
                    } catch {
                        dump(error)
                    }
                }
        }

        let contentView = RootView(appOptions: self.appOptions, document: document)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        NotificationCenter.default.post(name: UIPasteboard.changedNotification, object: "foo")

        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        withAnimation(.none) { appOptions.linkDescription = "" }

        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        withAnimation(.none) { appOptions.handlingLink = false }

        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
