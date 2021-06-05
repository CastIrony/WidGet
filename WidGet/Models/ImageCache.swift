//
//  ImageCache.swift
//  WidGet
//
//  Created by Joel Bernstein on 9/24/20.
//

import ImageIO
import UIKit

let queue = DispatchQueue.main // DispatchQueue(label: "com.castirony.widget.imagecache")//, attributes: .concurrent)

class ImageCache {
    static func cacheFileURL(for identifier: String, baked: Bool = false) -> URL? {
        let validCharacters = CharacterSet(charactersIn: "/").inverted

        if
            let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.suiteName),
            let normalizedURLString = identifier.addingPercentEncoding(withAllowedCharacters: validCharacters)
        {
            return baseURL.appendingPathComponent("image-cache\(baked ? "-baked" : "")-\(normalizedURLString)")
        }

        return nil
    }

    static let shared = ImageCache()

    var localCache: [String: UIImage] = [:]

    func storeImageData(_ imageData: Data, for identifier: String) {
        if let cacheFileURL = ImageCache.cacheFileURL(for: identifier) {
            do {
                try imageData.write(to: cacheFileURL)
            } catch {
                dump(error)
            }
        }
    }

    func bakeThumbnail(for identifier: String, thumbnailSize: CGSize, sizingMode: ContentPanelModel.ImageResizingMode, contentAlignment: ContentPanelModel.ContentAlignment, completion: @escaping () -> Void)
    {
        queue.async {
            if
                let originalCacheFileURL = ImageCache.cacheFileURL(for: identifier),
                let bakedCacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: true),
                let originalImage = UIImage(contentsOfFile: originalCacheFileURL.path),
                let thumbnailImage = originalImage.thumbnail(thumbnailSize: thumbnailSize, sizingMode: sizingMode, contentAlignment: contentAlignment),
                let thumbnailData = thumbnailImage.pngData()
            {
                do {
                    try thumbnailData.write(to: bakedCacheFileURL)

                    completion()
                    return
                } catch {
                    dump(error)
                }
            }

            completion()
        }
    }

    func downloadNeeded(for remoteURL: URL) -> Bool {
        let fileExists = (try? ImageCache.cacheFileURL(for: remoteURL.absoluteString)?.checkResourceIsReachable()) ?? false

        return !fileExists
    }

    func image(for identifier: String?, usePrebaked: Bool = false) -> UIImage? {
        guard let identifier = identifier else { return nil }

        if usePrebaked {
            if
                let cacheFileURL = ImageCache.cacheFileURL(for: identifier, baked: true),
                let data = try? Data(contentsOf: cacheFileURL),
                let uiImage = UIImage(data: data)
            {
                return uiImage
            }

            return nil
        } else {
            if let uiImage = localCache[identifier] {
                return uiImage
            }

            if
                let cacheFileURL = ImageCache.cacheFileURL(for: identifier),
                let data = try? Data(contentsOf: cacheFileURL)
            {
                if let uiImage = UIImage(data: data) {
                    localCache[identifier] = uiImage

                    return uiImage
                }
            }
        }

        return nil
    }
}

extension UIImage {
    static func resizedImageFrame(originalSize: CGSize, thumbnailSize: CGSize, sizingMode: ContentPanelModel.ImageResizingMode, contentAlignment: ContentPanelModel.ContentAlignment) -> CGRect
    {
        var imageSize: CGSize
        var imageOriginX: CGFloat
        var imageOriginY: CGFloat

        let originalRatio = originalSize.width / originalSize.height
        let thumbnailRatio = thumbnailSize.width / thumbnailSize.height

        switch sizingMode {
        case .fullSize: imageSize = originalSize
        case .stretch: imageSize = thumbnailSize
        case .scaleToFit: imageSize = originalRatio < thumbnailRatio ? CGSize(width: thumbnailSize.height * originalRatio, height: thumbnailSize.height) : CGSize(width: thumbnailSize.width, height: thumbnailSize.width / originalRatio)
        case .scaleToFill: imageSize = originalRatio < thumbnailRatio ? CGSize(width: thumbnailSize.width, height: thumbnailSize.width / originalRatio) : CGSize(width: thumbnailSize.height * originalRatio, height: thumbnailSize.height)
        }

        switch contentAlignment {
        case .topLeading, .leading, .bottomLeading: imageOriginX = 0
        case .top, .center, .bottom: imageOriginX = (thumbnailSize.width - imageSize.width) * 0.5
        case .topTrailing, .trailing, .bottomTrailing: imageOriginX = (thumbnailSize.width - imageSize.width)
        }

        switch contentAlignment {
        case .topLeading, .top, .topTrailing: imageOriginY = 0
        case .leading, .center, .trailing: imageOriginY = (thumbnailSize.height - imageSize.height) * 0.5
        case .bottomLeading, .bottom, .bottomTrailing: imageOriginY = (thumbnailSize.height - imageSize.height)
        }

        return CGRect(origin: CGPoint(x: imageOriginX, y: imageOriginY), size: imageSize)
    }

    static func thumbnailSize(originalSize: CGSize, aspectRatio: CGFloat) -> CGSize {
        let originalRatio = originalSize.width / originalSize.height
        return originalRatio > aspectRatio ? CGSize(width: originalSize.height * aspectRatio, height: originalSize.height) : CGSize(width: originalSize.width, height: originalSize.width / aspectRatio)
    }

    func thumbnail(maxThumbnailSize: CGSize) -> UIImage? {
        let frame = Self.resizedImageFrame(originalSize: size, thumbnailSize: maxThumbnailSize, sizingMode: .scaleToFit, contentAlignment: .center)

        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1)

        draw(in: CGRect(origin: CGPoint.zero, size: frame.size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }

    func thumbnail(thumbnailSize: CGSize, sizingMode: ContentPanelModel.ImageResizingMode, contentAlignment: ContentPanelModel.ContentAlignment) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0)

        let frame = Self.resizedImageFrame(originalSize: size, thumbnailSize: thumbnailSize, sizingMode: sizingMode, contentAlignment: contentAlignment)

        draw(in: frame)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }

    func cropped(to aspectRatio: CGFloat) -> UIImage? {
        return thumbnail(thumbnailSize: Self.thumbnailSize(originalSize: size, aspectRatio: aspectRatio), sizingMode: .scaleToFill, contentAlignment: .center)
    }
}
