//
//  RemoteResourceLoader.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/23/20.
//

import FeedKit
import Foundation
import iCalKit
import SwiftSoup
import SwiftUI

struct RemoteResourceLoader {
    struct Response {
        let resourceURL: URL
        let data: Data
        let contentType: ContentPanelModel.ContentType
        let contentTitle: String?
        let contentItems: [ContentPanelModel.ItemModel]
    }

    typealias Completion = (_ response: Response?, _ errorMessage: String?) -> Void

    static func loadResource(from targetURL: URL, forcedMimeType: String? = nil, completion: @escaping Completion)
    {
        print("starting data task \(targetURL)")
        let dataTask = URLSession.shared.dataTask(with: targetURL) {
            data, response, error in

            guard let data = data, let response = response else { completion(nil, error?.localizedDescription); return }

            switch forcedMimeType ?? response.mimeType {
            case "image/gif", "image/png", "image/jpeg":
                completion(Response(resourceURL: targetURL, data: data, contentType: .remoteImage, contentTitle: nil, contentItems: []), nil)

            case "text/html":
                handleHTMLResponse(response: response, data: data, completion: completion)

            case "text/xml", "application/xml", "application/rss+xml", "application/atom+xml", "application/json":
                handleRSSResponse(response: response, data: data, completion: completion)

            case "text/calendar":
                handleCalendarResponse(response: response, data: data, completion: completion)

            case "application/pdf":
                handlePDFResponse(response: response, data: data, completion: completion)

            default:
                completion(nil, "Content type is unrecognized")
            }
        }

        dataTask.resume()
    }

    static func handleHTMLResponse(response: URLResponse, data: Data, completion: @escaping Completion)
    {
        guard
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString, response.url?.absoluteString ?? "")
        else {
            completion(nil, "Unable to find a remote feed")
            return
        }

        if
            let rssLink = try? document.select("link[type=application/rss+xml]").first(),
            let rssURLString = try? rssLink.attr("href"),
            let rssURL = URL(string: rssURLString, relativeTo: response.url)
        {
            loadResource(from: rssURL, completion: completion)
        } else if
            let channelIDMeta = try? document.select("meta[itemProp=channelId]"),
            let channelID = try? channelIDMeta.attr("content"),
            channelID.count > 0,
            let rssURL = URL(string: "https://www.youtube.com/feeds/videos.xml?channel_id=\(channelID)")
        {
            loadResource(from: rssURL, completion: completion) // handle youtube occasionally forgetting to include the rss link
        } else if
            let channelIDRange = htmlString.range(of: "channelId")
        {
            let channelIDStart = htmlString.index(channelIDRange.upperBound, offsetBy: 3)
            let channelIDEnd = htmlString.index(channelIDStart, offsetBy: 24)
            let channelID = htmlString[Range(uncheckedBounds: (channelIDStart, channelIDEnd))]

            if channelID.count > 0, let rssURL = URL(string: "https://www.youtube.com/feeds/videos.xml?channel_id=\(channelID)")
            {
                loadResource(from: rssURL, completion: completion) // handle youtube occasionally forgetting to include the rss link
            } else {
                completion(nil, "Unable to find a remote feed")
            }
        } else {
            completion(nil, "Unable to find a remote feed")
        }
    }

    static func handleCalendarResponse(response: URLResponse, data: Data, completion: @escaping Completion)
    {
        guard
            let string = String(data: data, encoding: .utf8)
        else {
            completion(nil, "Unable to find a remote calendar")
            return
        }

        var contentItems: [ContentPanelModel.ItemModel] = []

        let foo = iCal.load(string: string)

        for calendar in foo {
            for subcomponent in calendar.subComponents {
                if
                    let event = subcomponent as? Event,
                    let title = event.summary ?? event.descr ?? event.location
                {
                    let date = event.dtstart ?? event.dtend ?? event.dtstamp
                    let contentItem = ContentPanelModel.ItemModel(title: title, body: "", date: date)
                    contentItems.append(contentItem)
                }
            }
        }

        completion(Response(resourceURL: response.url!, data: data, contentType: .remoteCalendar, contentTitle: nil, contentItems: contentItems), nil)
    }

    static func handlePDFResponse(response: URLResponse, data: Data, completion: @escaping Completion)
    {
        guard
            let dataProvider = CGDataProvider(data: data as CFData),
            let document = CGPDFDocument(dataProvider),
            let page = document.page(at: 1)
        else {
            completion(nil, "Unable to load PDF")
            return
        }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        completion(Response(resourceURL: response.url!, data: img.pngData()!, contentType: .remoteImage, contentTitle: nil, contentItems: []), nil)
    }

    static func handleRSSResponse(response: URLResponse, data: Data, completion: @escaping Completion)
    {
        let parser = FeedParser(data: data)

        parser.parseAsync {
            result in

            switch result {
            case let .success(feed):

                let group = DispatchGroup()

                let contentTitle: String? = feed.rssFeed?.title ?? feed.atomFeed?.title
                var contentItems: [ContentPanelModel.ItemModel] = []

                var thumbnailsFound: Bool = false

                for item in feed.rssFeed?.items /* ?.prefix(upTo: 20) */ ?? [] {
                    if let title = item.title {
                        let linkURLString = item.link
                        let imageURLString = item.media?.mediaGroup?.mediaContents?.first?.attributes?.url ?? item.media?.mediaThumbnails?.first?.attributes?.url ?? (try? (try? SwiftSoup.parseBodyFragment(item.content?.contentEncoded ?? ""))?.getElementsByTag("img").first()?.attr("src"))
                        let date = item.pubDate
                        let body = (try? SwiftSoup.clean(item.content?.contentEncoded ?? "", Whitelist.none())) ?? ""

                        let linkURL = linkURLString == nil ? nil : URL(string: linkURLString!)
                        let imageURL = imageURLString == nil ? nil : URL(string: imageURLString!)

                        let contentItem = ContentPanelModel.ItemModel(title: title, body: body, date: date, linkURL: linkURL, imageURL: imageURL)

//                            let contentItemsIndex = contentItems.count

                        contentItems.append(contentItem)

                        if let imageURL = imageURL {
                            thumbnailsFound = true

                            if ImageCache.shared.downloadNeeded(for: imageURL) {
                                group.enter()

                                loadResource(from: imageURL) {
                                    response, _ in

                                    if let imageData = response?.data {
                                        if imageURL.absoluteString.contains("ytimg"), let croppedData = UIImage(data: imageData)?.cropped(to: CGFloat(16) / CGFloat(9))?.pngData()
                                        {
                                            ImageCache.shared.storeImageData(croppedData, for: imageURL.absoluteString)
                                        } else {
                                            ImageCache.shared.storeImageData(imageData, for: imageURL.absoluteString)
                                        }
                                    }

                                    group.leave()
                                }
                            }
                        }
                    }
                }

                for entry in feed.atomFeed?.entries /* ?.prefix(upTo: 20) */ ?? [] {
                    if let title = entry.title {
                        let linkURLString = entry.links?.last?.attributes?.href
                        let imageURLString = entry.media?.mediaGroup?.mediaThumbnail?.attributes?.url ?? (try? (try? SwiftSoup.parseBodyFragment(entry.content?.value ?? ""))?.getElementsByTag("img").first()?.attr("src"))
                        let date = entry.updated ?? entry.published
                        let body = (try? SwiftSoup.clean(entry.content?.value ?? "", Whitelist.none())) ?? ""

                        let linkURL = linkURLString == nil ? nil : URL(string: linkURLString!)
                        let imageURL = imageURLString == nil ? nil : URL(string: imageURLString!)

                        let contentItem = ContentPanelModel.ItemModel(title: title, body: body, date: date, linkURL: linkURL, imageURL: imageURL)

//                            let contentItemsIndex = contentItems.count

                        contentItems.append(contentItem)

                        if let imageURL = imageURL {
                            thumbnailsFound = true

                            if ImageCache.shared.downloadNeeded(for: imageURL) {
                                group.enter()

                                loadResource(from: imageURL) {
                                    response, _ in

                                    if let imageData = response?.data {
                                        if imageURL.absoluteString.contains("ytimg"), let croppedData = UIImage(data: imageData)?.cropped(to: CGFloat(16) / CGFloat(9))?.pngData()
                                        {
                                            ImageCache.shared.storeImageData(croppedData, for: imageURL.absoluteString)
                                        } else {
                                            ImageCache.shared.storeImageData(imageData, for: imageURL.absoluteString)
                                        }
                                    }

                                    group.leave()
                                }
                            }
                        }
                    }
                }

                group.notify(queue: .main) {
                    completion(Response(resourceURL: response.url!, data: data, contentType: thumbnailsFound ? .remoteFeedGrid : .remoteFeedList, contentTitle: contentTitle, contentItems: contentItems), nil)
                }

            case let .failure(error):
                completion(nil, error.localizedDescription)
            }
        }
    }
}
