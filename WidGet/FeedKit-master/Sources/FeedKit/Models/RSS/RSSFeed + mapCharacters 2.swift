//
//  RSSFeed + mapCharacters.swift
//
//  Copyright (c) 2016 - 2018 Nuno Manuel Dias
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

extension RSSFeed {
    /// Maps the characters in the specified string to the `RSSFeed` model.
    ///
    /// - Parameters:
    ///   - string: The string to map to the model.
    ///   - path: The path of feed's element.
    func map(_ string: String, for path: RSSPath) {
        switch path {
        case .rssChannelTitle: title = title?.appending(string) ?? string
        case .rssChannelLink: link = link?.appending(string) ?? string
        case .rssChannelDescription: description = description?.appending(string) ?? string
        case .rssChannelLanguage: language = language?.appending(string) ?? string
        case .rssChannelCopyright: copyright = copyright?.appending(string) ?? string
        case .rssChannelManagingEditor: managingEditor = managingEditor?.appending(string) ?? string
        case .rssChannelWebMaster: webMaster = webMaster?.appending(string) ?? string
        case .rssChannelPubDate: pubDate = string.toPermissiveDate()
        case .rssChannelLastBuildDate: lastBuildDate = string.toPermissiveDate()
        case .rssChannelCategory: categories?.last?.value = categories?.last?.value?.appending(string) ?? string
        case .rssChannelGenerator: generator = generator?.appending(string) ?? string
        case .rssChannelDocs: docs = docs?.appending(string) ?? string
        case .rssChannelRating: rating = rating?.appending(string) ?? string
        case .rssChannelTTL: ttl = Int(string)
        case .rssChannelImageURL: image?.url = image?.url?.appending(string) ?? string
        case .rssChannelImageTitle: image?.title = image?.title?.appending(string) ?? string
        case .rssChannelImageLink: image?.link = image?.link?.appending(string) ?? string
        case .rssChannelImageWidth: image?.width = Int(string)
        case .rssChannelImageHeight: image?.height = Int(string)
        case .rssChannelImageDescription: image?.description = image?.description?.appending(string) ?? string
        case .rssChannelTextInputTitle: textInput?.title = textInput?.title?.appending(string) ?? string
        case .rssChannelTextInputDescription: textInput?.description = textInput?.description?.appending(string) ?? string
        case .rssChannelTextInputName: textInput?.name = textInput?.name?.appending(string) ?? string
        case .rssChannelTextInputLink: textInput?.link = textInput?.link?.appending(string) ?? string
        case .rssChannelSkipHoursHour:
            if let hour = RSSFeedSkipHour(string), 0 ... 23 ~= hour {
                skipHours?.append(hour)
            }
        case .rssChannelSkipDaysDay:
            if let day = RSSFeedSkipDay(rawValue: string) {
                skipDays?.append(day)
            }
        case .rssChannelItemTitle: items?.last?.title = items?.last?.title?.appending(string) ?? string
        case .rssChannelItemLink: items?.last?.link = items?.last?.link?.appending(string) ?? string
        case .rssChannelItemDescription: items?.last?.description = items?.last?.description?.appending(string) ?? string
        case .rssChannelItemAuthor: items?.last?.author = items?.last?.author?.appending(string) ?? string
        case .rssChannelItemCategory: items?.last?.categories?.last?.value = items?.last?.categories?.last?.value?.appending(string) ?? string
        case .rssChannelItemComments: items?.last?.comments = items?.last?.comments?.appending(string) ?? string
        case .rssChannelItemGUID: items?.last?.guid?.value = items?.last?.guid?.value?.appending(string) ?? string
        case .rssChannelItemPubDate:
            let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !string.isEmpty {
                items?.last?.pubDate = string.toPermissiveDate()
            }
        case .rssChannelItemSource: items?.last?.source?.value = items?.last?.source?.value?.appending(string) ?? string
        case .rssChannelItemContentEncoded: items?.last?.content?.contentEncoded = items?.last?.content?.contentEncoded?.appending(string) ?? string
        case .rssChannelSyndicationUpdatePeriod: syndication?.syUpdatePeriod = SyndicationUpdatePeriod(rawValue: string)
        case .rssChannelSyndicationUpdateFrequency: syndication?.syUpdateFrequency = Int(string)
        case .rssChannelSyndicationUpdateBase: syndication?.syUpdateBase = string.toPermissiveDate()
        case .rssChannelDublinCoreTitle: dublinCore?.dcTitle = dublinCore?.dcTitle?.appending(string) ?? string
        case .rssChannelDublinCoreCreator: dublinCore?.dcCreator = dublinCore?.dcCreator?.appending(string) ?? string
        case .rssChannelDublinCoreSubject: dublinCore?.dcSubject = dublinCore?.dcSubject?.appending(string) ?? string
        case .rssChannelDublinCoreDescription: dublinCore?.dcDescription = dublinCore?.dcDescription?.appending(string) ?? string
        case .rssChannelDublinCorePublisher: dublinCore?.dcPublisher = dublinCore?.dcPublisher?.appending(string) ?? string
        case .rssChannelDublinCoreContributor: dublinCore?.dcContributor = dublinCore?.dcContributor?.appending(string) ?? string
        case .rssChannelDublinCoreDate: dublinCore?.dcDate = string.toPermissiveDate()
        case .rssChannelDublinCoreType: dublinCore?.dcType = dublinCore?.dcType?.appending(string) ?? string
        case .rssChannelDublinCoreFormat: dublinCore?.dcFormat = dublinCore?.dcFormat?.appending(string) ?? string
        case .rssChannelDublinCoreIdentifier: dublinCore?.dcIdentifier = dublinCore?.dcIdentifier?.appending(string) ?? string
        case .rssChannelDublinCoreSource: dublinCore?.dcSource = dublinCore?.dcSource?.appending(string) ?? string
        case .rssChannelDublinCoreLanguage: dublinCore?.dcLanguage = dublinCore?.dcLanguage?.appending(string) ?? string
        case .rssChannelDublinCoreRelation: dublinCore?.dcRelation = dublinCore?.dcRelation?.appending(string) ?? string
        case .rssChannelDublinCoreCoverage: dublinCore?.dcCoverage = dublinCore?.dcCoverage?.appending(string) ?? string
        case .rssChannelDublinCoreRights: dublinCore?.dcRights = dublinCore?.dcRights?.appending(string) ?? string
        case .rssChannelItemDublinCoreTitle: items?.last?.dublinCore?.dcTitle = items?.last?.dublinCore?.dcTitle?.appending(string) ?? string
        case .rssChannelItemDublinCoreCreator: items?.last?.dublinCore?.dcCreator = items?.last?.dublinCore?.dcCreator?.appending(string) ?? string
        case .rssChannelItemDublinCoreSubject: items?.last?.dublinCore?.dcSubject = items?.last?.dublinCore?.dcSubject?.appending(string) ?? string
        case .rssChannelItemDublinCoreDescription: items?.last?.dublinCore?.dcDescription = items?.last?.dublinCore?.dcDescription?.appending(string) ?? string
        case .rssChannelItemDublinCorePublisher: items?.last?.dublinCore?.dcPublisher = items?.last?.dublinCore?.dcPublisher?.appending(string) ?? string
        case .rssChannelItemDublinCoreContributor: items?.last?.dublinCore?.dcContributor = items?.last?.dublinCore?.dcContributor?.appending(string) ?? string
        case .rssChannelItemDublinCoreDate: items?.last?.dublinCore?.dcDate = string.toPermissiveDate()
        case .rssChannelItemDublinCoreType: items?.last?.dublinCore?.dcType = items?.last?.dublinCore?.dcType?.appending(string) ?? string
        case .rssChannelItemDublinCoreFormat: items?.last?.dublinCore?.dcFormat = items?.last?.dublinCore?.dcFormat?.appending(string) ?? string
        case .rssChannelItemDublinCoreIdentifier: items?.last?.dublinCore?.dcIdentifier = items?.last?.dublinCore?.dcIdentifier?.appending(string) ?? string
        case .rssChannelItemDublinCoreSource: items?.last?.dublinCore?.dcSource = items?.last?.dublinCore?.dcSource?.appending(string) ?? string
        case .rssChannelItemDublinCoreLanguage: items?.last?.dublinCore?.dcLanguage = items?.last?.dublinCore?.dcLanguage?.appending(string) ?? string
        case .rssChannelItemDublinCoreRelation: items?.last?.dublinCore?.dcRelation = items?.last?.dublinCore?.dcRelation?.appending(string) ?? string
        case .rssChannelItemDublinCoreCoverage: items?.last?.dublinCore?.dcCoverage = items?.last?.dublinCore?.dcCoverage?.appending(string) ?? string
        case .rssChannelItemDublinCoreRights: items?.last?.dublinCore?.dcRights = items?.last?.dublinCore?.dcRights?.appending(string) ?? string
        case .rssChannelItunesAuthor: iTunes?.iTunesAuthor = iTunes?.iTunesAuthor?.appending(string) ?? string
        case .rssChannelItunesBlock: iTunes?.iTunesBlock = iTunes?.iTunesBlock?.appending(string) ?? string
        case .rssChannelItunesExplicit: iTunes?.iTunesExplicit = iTunes?.iTunesExplicit?.appending(string) ?? string
        case .rssChannelItunesComplete: iTunes?.iTunesComplete = iTunes?.iTunesComplete?.appending(string) ?? string
        case .rssChannelItunesNewFeedURL: iTunes?.iTunesNewFeedURL = iTunes?.iTunesNewFeedURL?.appending(string) ?? string
        case .rssChannelItunesOwnerName: iTunes?.iTunesOwner?.name = iTunes?.iTunesOwner?.name?.appending(string) ?? string
        case .rssChannelItunesOwnerEmail: iTunes?.iTunesOwner?.email = iTunes?.iTunesOwner?.email?.appending(string) ?? string
        case .rssChannelItunesTitle: iTunes?.iTunesTitle = iTunes?.iTunesTitle?.appending(string) ?? string
        case .rssChannelItunesSubtitle: iTunes?.iTunesSubtitle = iTunes?.iTunesSubtitle?.appending(string) ?? string
        case .rssChannelItunesSummary: iTunes?.iTunesSummary = iTunes?.iTunesSummary?.appending(string) ?? string
        case .rssChannelItunesKeywords: iTunes?.iTunesKeywords = iTunes?.iTunesKeywords?.appending(string) ?? string
        case .rssChannelItunesType: iTunes?.iTunesType = iTunes?.iTunesType?.appending(string) ?? string
        case .rssChannelItemItunesAuthor: items?.last?.iTunes?.iTunesAuthor = items?.last?.iTunes?.iTunesAuthor?.appending(string) ?? string
        case .rssChannelItemItunesBlock: items?.last?.iTunes?.iTunesBlock = items?.last?.iTunes?.iTunesBlock?.appending(string) ?? string
        case .rssChannelItemItunesDuration: items?.last?.iTunes?.iTunesDuration = string.toDuration()
        case .rssChannelItemItunesExplicit: items?.last?.iTunes?.iTunesExplicit = items?.last?.iTunes?.iTunesExplicit?.appending(string) ?? string
        case .rssChannelItemItunesIsClosedCaptioned: items?.last?.iTunes?.isClosedCaptioned = items?.last?.iTunes?.isClosedCaptioned?.appending(string) ?? string
        case .rssChannelItemItunesOrder: items?.last?.iTunes?.iTunesOrder = Int(string)
        case .rssChannelItemItunesTitle: items?.last?.iTunes?.iTunesTitle = items?.last?.iTunes?.iTunesTitle?.appending(string) ?? string
        case .rssChannelItemItunesSubtitle: items?.last?.iTunes?.iTunesSubtitle = items?.last?.iTunes?.iTunesSubtitle?.appending(string) ?? string
        case .rssChannelItemItunesSummary: items?.last?.iTunes?.iTunesSummary = items?.last?.iTunes?.iTunesSummary?.appending(string) ?? string
        case .rssChannelItemItunesKeywords: items?.last?.iTunes?.iTunesKeywords = items?.last?.iTunes?.iTunesKeywords?.appending(string) ?? string
        case .rssChannelItemItunesEpisodeType: items?.last?.iTunes?.iTunesEpisodeType = items?.last?.iTunes?.iTunesEpisodeType?.appending(string) ?? string
        case .rssChannelItemItunesSeason: items?.last?.iTunes?.iTunesSeason = Int(string)
        case .rssChannelItemItunesEpisode: items?.last?.iTunes?.iTunesEpisode = Int(string)
        case .rssChannelItemMediaThumbnail: items?.last?.media?.mediaThumbnails?.last?.value = items?.last?.media?.mediaThumbnails?.last?.value?.appending(string) ?? string
        case .rssChannelItemMediaLicense: items?.last?.media?.mediaLicense?.value = items?.last?.media?.mediaLicense?.value?.appending(string) ?? string
        case .rssChannelItemMediaRestriction: items?.last?.media?.mediaRestriction?.value = items?.last?.media?.mediaRestriction?.value?.appending(string) ?? string
        case .rssChannelItemMediaContentTitle: items?.last?.media?.mediaContents?.last?.mediaTitle?.value = items?.last?.media?.mediaContents?.last?.mediaTitle?.value?.appending(string) ?? string
        case .rssChannelItemMediaContentKeywords:
            if !string.isEmpty {
                let keywords = string
                    .components(separatedBy: ",")
                    .map { string -> String in
                        string.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                items?.last?.media?.mediaContents?.last?.mediaKeywords?.append(contentsOf: keywords)
            }

        case .rssChannelItemMediaContentCategory: items?.last?.media?.mediaContents?.last?.mediaCategory?.value = items?.last?.media?.mediaContents?.last?.mediaCategory?.value?.appending(string) ?? string
        case .rssChannelItemMediaContentDescription: items?.last?.media?.mediaContents?.last?.mediaDescription?.value = items?.last?.media?.mediaDescription?.value?.appending(string) ?? string
        case .rssChannelItemMediaContentPlayer: items?.last?.media?.mediaContents?.last?.mediaPlayer?.value = items?.last?.media?.mediaContents?.last?.mediaPlayer?.value?.appending(string) ?? string
        case .rssChannelItemMediaContentThumbnail: items?.last?.media?.mediaContents?.last?.mediaThumbnails?.last?.value = items?.last?.media?.mediaContents?.last?.mediaThumbnails?.last?.value?.appending(string) ?? string
        case .rssChannelItemMediaCommunityMediaTags: items?.last?.media?.mediaCommunity?.mediaTags = MediaTag.tagsFrom(string: string)
        case .rssChannelItemMediaCommentsMediaComment: items?.last?.media?.mediaComments?.append(string)
        case .rssChannelItemMediaEmbedMediaParam: items?.last?.media?.mediaEmbed?.mediaParams?.last?.value = items?.last?.media?.mediaEmbed?.mediaParams?.last?.value?.appending(string) ?? string
        case .rssChannelItemMediaGroupMediaCredit: items?.last?.media?.mediaGroup?.mediaCredits?.last?.value = items?.last?.media?.mediaGroup?.mediaCredits?.last?.value?.appending(string) ?? string
        case .rssChannelItemMediaGroupMediaCategory: items?.last?.media?.mediaGroup?.mediaCategory?.value = items?.last?.media?.mediaGroup?.mediaCategory?.value?.appending(string) ?? string
        case .rssChannelItemMediaGroupMediaRating: items?.last?.media?.mediaGroup?.mediaRating?.value = items?.last?.media?.mediaGroup?.mediaRating?.value?.appending(string) ?? string
        case .rssChannelItemMediaResponsesMediaResponse: items?.last?.media?.mediaResponses?.append(string)
        case .rssChannelItemMediaBackLinksBackLink: items?.last?.media?.mediaBackLinks?.append(string)
        case .rssChannelItemMediaLocationPosition: items?.last?.media?.mediaLocation?.mapFrom(latLng: string)
        case .rssChannelItemMediaScenesMediaSceneSceneTitle: items?.last?.media?.mediaScenes?.last?.sceneTitle = items?.last?.media?.mediaScenes?.last?.sceneTitle?.appending(string) ?? string
        case .rssChannelItemMediaScenesMediaSceneSceneDescription: items?.last?.media?.mediaScenes?.last?.sceneDescription = items?.last?.media?.mediaScenes?.last?.sceneDescription?.appending(string) ?? string
        case .rssChannelItemMediaScenesMediaSceneSceneStartTime: items?.last?.media?.mediaScenes?.last?.sceneStartTime = string.toDuration()
        case .rssChannelItemMediaScenesMediaSceneSceneEndTime: items?.last?.media?.mediaScenes?.last?.sceneEndTime = string.toDuration()
        default: break
        }
    }

    /// Maps the characters in the specified string to the `RSSFeed` model.
    ///
    /// - Parameters:
    ///   - string: The string to map to the model.
    ///   - path: The path of feed's element.
    func map(_ string: String, for path: RDFPath) {
        switch path {
        case .rdfChannelTitle: title = title?.appending(string) ?? string
        case .rdfChannelLink: link = link?.appending(string) ?? string
        case .rdfChannelDescription: description = description?.appending(string) ?? string
        case .rdfChannelImage: image?.url = image?.url?.appending(string) ?? string
        case .rdfItemTitle: items?.last?.title = items?.last?.title?.appending(string) ?? string
        case .rdfItemLink: items?.last?.link = items?.last?.link?.appending(string) ?? string
        case .rdfItemDescription: items?.last?.description = items?.last?.description?.appending(string) ?? string
        case .rdfChannelSyndicationUpdatePeriod: syndication?.syUpdatePeriod = SyndicationUpdatePeriod(rawValue: string)
        case .rdfChannelSyndicationUpdateFrequency: syndication?.syUpdateFrequency = Int(string)
        case .rdfChannelSyndicationUpdateBase: syndication?.syUpdateBase = string.toPermissiveDate()
        case .rdfChannelDublinCoreTitle: dublinCore?.dcTitle = dublinCore?.dcTitle?.appending(string) ?? string
        case .rdfChannelDublinCoreCreator: dublinCore?.dcCreator = dublinCore?.dcCreator?.appending(string) ?? string
        case .rdfChannelDublinCoreSubject: dublinCore?.dcSubject = dublinCore?.dcSubject?.appending(string) ?? string
        case .rdfChannelDublinCoreDescription: dublinCore?.dcDescription = dublinCore?.dcDescription?.appending(string) ?? string
        case .rdfChannelDublinCorePublisher: dublinCore?.dcPublisher = dublinCore?.dcPublisher?.appending(string) ?? string
        case .rdfChannelDublinCoreContributor: dublinCore?.dcContributor = dublinCore?.dcContributor?.appending(string) ?? string
        case .rdfChannelDublinCoreDate: dublinCore?.dcDate = string.toPermissiveDate()
        case .rdfChannelDublinCoreType: dublinCore?.dcType = dublinCore?.dcType?.appending(string) ?? string
        case .rdfChannelDublinCoreFormat: dublinCore?.dcFormat = dublinCore?.dcFormat?.appending(string) ?? string
        case .rdfChannelDublinCoreIdentifier: dublinCore?.dcIdentifier = dublinCore?.dcIdentifier?.appending(string) ?? string
        case .rdfChannelDublinCoreSource: dublinCore?.dcSource = dublinCore?.dcSource?.appending(string) ?? string
        case .rdfChannelDublinCoreLanguage: dublinCore?.dcLanguage = dublinCore?.dcLanguage?.appending(string) ?? string
        case .rdfChannelDublinCoreRelation: dublinCore?.dcRelation = dublinCore?.dcRelation?.appending(string) ?? string
        case .rdfChannelDublinCoreCoverage: dublinCore?.dcCoverage = dublinCore?.dcCoverage?.appending(string) ?? string
        case .rdfChannelDublinCoreRights: dublinCore?.dcRights = dublinCore?.dcRights?.appending(string) ?? string
        case .rdfItemDublinCoreTitle: items?.last?.dublinCore?.dcTitle = items?.last?.dublinCore?.dcTitle?.appending(string) ?? string
        case .rdfItemDublinCoreCreator: items?.last?.dublinCore?.dcCreator = items?.last?.dublinCore?.dcCreator?.appending(string) ?? string
        case .rdfItemDublinCoreSubject: items?.last?.dublinCore?.dcSubject = items?.last?.dublinCore?.dcSubject?.appending(string) ?? string
        case .rdfItemDublinCoreDescription: items?.last?.dublinCore?.dcDescription = items?.last?.dublinCore?.dcDescription?.appending(string) ?? string
        case .rdfItemDublinCorePublisher: items?.last?.dublinCore?.dcPublisher = items?.last?.dublinCore?.dcPublisher?.appending(string) ?? string
        case .rdfItemDublinCoreContributor: items?.last?.dublinCore?.dcContributor = items?.last?.dublinCore?.dcContributor?.appending(string) ?? string
        case .rdfItemDublinCoreDate: items?.last?.dublinCore?.dcDate = string.toPermissiveDate()
        case .rdfItemDublinCoreType: items?.last?.dublinCore?.dcType = items?.last?.dublinCore?.dcType?.appending(string) ?? string
        case .rdfItemDublinCoreFormat: items?.last?.dublinCore?.dcFormat = items?.last?.dublinCore?.dcFormat?.appending(string) ?? string
        case .rdfItemDublinCoreIdentifier: items?.last?.dublinCore?.dcIdentifier = items?.last?.dublinCore?.dcIdentifier?.appending(string) ?? string
        case .rdfItemDublinCoreSource: items?.last?.dublinCore?.dcSource = items?.last?.dublinCore?.dcSource?.appending(string) ?? string
        case .rdfItemDublinCoreLanguage: items?.last?.dublinCore?.dcLanguage = items?.last?.dublinCore?.dcLanguage?.appending(string) ?? string
        case .rdfItemDublinCoreRelation: items?.last?.dublinCore?.dcRelation = items?.last?.dublinCore?.dcRelation?.appending(string) ?? string
        case .rdfItemDublinCoreCoverage: items?.last?.dublinCore?.dcCoverage = items?.last?.dublinCore?.dcCoverage?.appending(string) ?? string
        case .rdfItemDublinCoreRights: items?.last?.dublinCore?.dcRights = items?.last?.dublinCore?.dcRights?.appending(string) ?? string
        case .rdfItemContentEncoded: items?.last?.content?.contentEncoded = items?.last?.content?.contentEncoded?.appending(string) ?? string
        default: break
        }
    }
}
