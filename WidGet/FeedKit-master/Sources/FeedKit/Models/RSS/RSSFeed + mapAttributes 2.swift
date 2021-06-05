//
//  RSSFeed + mapAttributes.swift
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
    /// Maps the attributes of the specified dictionary for a given `RSSPath`
    /// to the `RSSFeed` model,
    ///
    /// - Parameters:
    ///   - attributes: The attribute dictionary to map to the model.
    ///   - path: The path of feed's element.
    func map(_ attributes: [String: String], for path: RSSPath) {
        switch path {
        case .rssChannelItem:

            if items == nil {
                items = []
            }

            items?.append(RSSFeedItem())

        case .rssChannelImage:

            if image == nil {
                image = RSSFeedImage()
            }

        case .rssChannelSkipDays:

            if skipDays == nil {
                skipDays = []
            }

        case .rssChannelSkipHours:

            if skipHours == nil {
                skipHours = []
            }

        case .rssChannelTextInput:

            if textInput == nil {
                textInput = RSSFeedTextInput()
            }

        case .rssChannelCategory:

            if categories == nil {
                categories = []
            }

            categories?.append(RSSFeedCategory(attributes: attributes))

        case .rssChannelCloud:

            if cloud == nil {
                cloud = RSSFeedCloud(attributes: attributes)
            }

        case .rssChannelItemCategory:

            if items?.last?.categories == nil {
                items?.last?.categories = []
            }

            items?.last?.categories?.append(RSSFeedItemCategory(attributes: attributes))

        case .rssChannelItemEnclosure:

            if items?.last?.enclosure == nil {
                items?.last?.enclosure = RSSFeedItemEnclosure(attributes: attributes)
            }

        case .rssChannelItemGUID:

            if items?.last?.guid == nil {
                items?.last?.guid = RSSFeedItemGUID(attributes: attributes)
            }

        case .rssChannelItemSource:

            if items?.last?.source == nil {
                items?.last?.source = RSSFeedItemSource(attributes: attributes)
            }

        case .rssChannelItemContentEncoded:

            if items?.last?.content == nil {
                items?.last?.content = ContentNamespace()
            }

        case
            .rssChannelSyndicationUpdateBase,
            .rssChannelSyndicationUpdatePeriod,
            .rssChannelSyndicationUpdateFrequency:

            if syndication == nil {
                syndication = SyndicationNamespace()
            }

        case
            .rssChannelDublinCoreTitle,
            .rssChannelDublinCoreCreator,
            .rssChannelDublinCoreSubject,
            .rssChannelDublinCoreDescription,
            .rssChannelDublinCorePublisher,
            .rssChannelDublinCoreContributor,
            .rssChannelDublinCoreDate,
            .rssChannelDublinCoreType,
            .rssChannelDublinCoreFormat,
            .rssChannelDublinCoreIdentifier,
            .rssChannelDublinCoreSource,
            .rssChannelDublinCoreLanguage,
            .rssChannelDublinCoreRelation,
            .rssChannelDublinCoreCoverage,
            .rssChannelDublinCoreRights:

            if dublinCore == nil {
                dublinCore = DublinCoreNamespace()
            }

        case
            .rssChannelItemDublinCoreTitle,
            .rssChannelItemDublinCoreCreator,
            .rssChannelItemDublinCoreSubject,
            .rssChannelItemDublinCoreDescription,
            .rssChannelItemDublinCorePublisher,
            .rssChannelItemDublinCoreContributor,
            .rssChannelItemDublinCoreDate,
            .rssChannelItemDublinCoreType,
            .rssChannelItemDublinCoreFormat,
            .rssChannelItemDublinCoreIdentifier,
            .rssChannelItemDublinCoreSource,
            .rssChannelItemDublinCoreLanguage,
            .rssChannelItemDublinCoreRelation,
            .rssChannelItemDublinCoreCoverage,
            .rssChannelItemDublinCoreRights:

            if items?.last?.dublinCore == nil {
                items?.last?.dublinCore = DublinCoreNamespace()
            }

        case
            .rssChannelItunesAuthor,
            .rssChannelItunesBlock,
            .rssChannelItunesCategory,
            .rssChannelItunesSubcategory,
            .rssChannelItunesImage,
            .rssChannelItunesExplicit,
            .rssChannelItunesComplete,
            .rssChannelItunesNewFeedURL,
            .rssChannelItunesOwner,
            .rssChannelItunesOwnerName,
            .rssChannelItunesOwnerEmail,
            .rssChannelItunesSubtitle,
            .rssChannelItunesSummary,
            .rssChannelItunesKeywords,
            .rssChannelItunesType:

            if iTunes == nil {
                iTunes = ITunesNamespace()
            }

            switch path {
            case .rssChannelItunesCategory:

                if iTunes?.iTunesCategories == nil {
                    iTunes?.iTunesCategories = []
                }

                iTunes?.iTunesCategories?.append(ITunesCategory(attributes: attributes))

            case .rssChannelItunesSubcategory:

                iTunes?.iTunesCategories?.last?.subcategory = ITunesSubCategory(attributes: attributes)

            case .rssChannelItunesImage:

                iTunes?.iTunesImage = ITunesImage(attributes: attributes)

            case .rssChannelItunesOwner:

                if iTunes?.iTunesOwner == nil {
                    iTunes?.iTunesOwner = ITunesOwner()
                }

            default: break
            }

        case
            .rssChannelItemItunesAuthor,
            .rssChannelItemItunesBlock,
            .rssChannelItemItunesDuration,
            .rssChannelItemItunesImage,
            .rssChannelItemItunesExplicit,
            .rssChannelItemItunesIsClosedCaptioned,
            .rssChannelItemItunesOrder,
            .rssChannelItemItunesTitle,
            .rssChannelItemItunesSubtitle,
            .rssChannelItemItunesSummary,
            .rssChannelItemItunesKeywords:

            if items?.last?.iTunes == nil {
                items?.last?.iTunes = ITunesNamespace()
            }

            switch path {
            case .rssChannelItemItunesImage:

                items?.last?.iTunes?.iTunesImage = ITunesImage(attributes: attributes)

            default: break
            }

            // MARK: Media

        case
            .rssChannelItemMediaThumbnail,
            .rssChannelItemMediaContent,
            .rssChannelItemMediaContentTitle,
            .rssChannelItemMediaContentDescription,
            .rssChannelItemMediaContentKeywords,
            .rssChannelItemMediaContentPlayer,
            .rssChannelItemMediaContentThumbnail,
            .rssChannelItemMediaContentCategory,
            .rssChannelItemMediaCommunity,
            .rssChannelItemMediaCommunityMediaStarRating,
            .rssChannelItemMediaCommunityMediaStatistics,
            .rssChannelItemMediaCommunityMediaTags,
            .rssChannelItemMediaComments,
            .rssChannelItemMediaCommentsMediaComment,
            .rssChannelItemMediaEmbed,
            .rssChannelItemMediaEmbedMediaParam,
            .rssChannelItemMediaResponses,
            .rssChannelItemMediaResponsesMediaResponse,
            .rssChannelItemMediaBackLinks,
            .rssChannelItemMediaBackLinksBackLink,
            .rssChannelItemMediaStatus,
            .rssChannelItemMediaPrice,
            .rssChannelItemMediaLicense,
            .rssChannelItemMediaSubTitle,
            .rssChannelItemMediaPeerLink,
            .rssChannelItemMediaLocation,
            .rssChannelItemMediaLocationPosition,
            .rssChannelItemMediaRestriction,
            .rssChannelItemMediaScenes,
            .rssChannelItemMediaScenesMediaScene,
            .rssChannelItemMediaGroup,
            .rssChannelItemMediaGroupMediaCategory,
            .rssChannelItemMediaGroupMediaCredit,
            .rssChannelItemMediaGroupMediaRating,
            .rssChannelItemMediaGroupMediaContent:

            if items?.last?.media == nil {
                items?.last?.media = MediaNamespace()
            }

            switch path {
            case .rssChannelItemMediaThumbnail:

                if items?.last?.media?.mediaThumbnails == nil {
                    items?.last?.media?.mediaThumbnails = []
                }

                items?.last?.media?.mediaThumbnails?.append(MediaThumbnail(attributes: attributes))

            case .rssChannelItemMediaContent:

                if items?.last?.media?.mediaContents == nil {
                    items?.last?.media?.mediaContents = []
                }

                items?.last?.media?.mediaContents?.append(MediaContent(attributes: attributes))

            case .rssChannelItemMediaContentTitle:

                if items?.last?.media?.mediaContents?.last?.mediaTitle == nil {
                    items?.last?.media?.mediaContents?.last?.mediaTitle = MediaTitle(attributes: attributes)
                }

            case .rssChannelItemMediaContentDescription:

                if items?.last?.media?.mediaContents?.last?.mediaDescription == nil {
                    items?.last?.media?.mediaContents?.last?.mediaDescription = MediaDescription(attributes: attributes)
                }

            case .rssChannelItemMediaContentKeywords:

                if items?.last?.media?.mediaContents?.last?.mediaKeywords == nil {
                    items?.last?.media?.mediaContents?.last?.mediaKeywords = []
                }

            case .rssChannelItemMediaContentCategory:

                if items?.last?.media?.mediaContents?.last?.mediaCategory == nil {
                    items?.last?.media?.mediaContents?.last?.mediaCategory = MediaCategory(attributes: attributes)
                }

            case .rssChannelItemMediaContentPlayer:

                if items?.last?.media?.mediaContents?.last?.mediaPlayer == nil {
                    items?.last?.media?.mediaContents?.last?.mediaPlayer = MediaPlayer(attributes: attributes)
                }

            case .rssChannelItemMediaContentThumbnail:

                if items?.last?.media?.mediaContents?.last?.mediaThumbnails == nil {
                    items?.last?.media?.mediaContents?.last?.mediaThumbnails = []
                }

                items?.last?.media?.mediaContents?.last?.mediaThumbnails?.append(MediaThumbnail(attributes: attributes))

            case .rssChannelItemMediaCommunity:

                if items?.last?.media?.mediaCommunity == nil {
                    items?.last?.media?.mediaCommunity = MediaCommunity()
                }

            case .rssChannelItemMediaCommunityMediaStarRating:

                if items?.last?.media?.mediaCommunity?.mediaStarRating == nil {
                    items?.last?.media?.mediaCommunity?.mediaStarRating = MediaStarRating(attributes: attributes)
                }

            case .rssChannelItemMediaCommunityMediaStatistics:

                if items?.last?.media?.mediaCommunity?.mediaStatistics == nil {
                    items?.last?.media?.mediaCommunity?.mediaStatistics = MediaStatistics(attributes: attributes)
                }

            case .rssChannelItemMediaCommunityMediaTags:

                if items?.last?.media?.mediaCommunity?.mediaTags == nil {
                    items?.last?.media?.mediaCommunity?.mediaTags = []
                }

            case .rssChannelItemMediaComments:

                if items?.last?.media?.mediaComments == nil {
                    items?.last?.media?.mediaComments = []
                }

            case .rssChannelItemMediaEmbed:

                if items?.last?.media?.mediaEmbed == nil {
                    items?.last?.media?.mediaEmbed = MediaEmbed(attributes: attributes)
                }

            case .rssChannelItemMediaEmbedMediaParam:

                if items?.last?.media?.mediaEmbed?.mediaParams == nil {
                    items?.last?.media?.mediaEmbed?.mediaParams = []
                }

                items?.last?.media?.mediaEmbed?.mediaParams?.append(MediaParam(attributes: attributes))

            case .rssChannelItemMediaResponses:

                if items?.last?.media?.mediaResponses == nil {
                    items?.last?.media?.mediaResponses = []
                }

            case .rssChannelItemMediaBackLinks:

                if items?.last?.media?.mediaBackLinks == nil {
                    items?.last?.media?.mediaBackLinks = []
                }

            case .rssChannelItemMediaStatus:

                if items?.last?.media?.mediaStatus == nil {
                    items?.last?.media?.mediaStatus = MediaStatus(attributes: attributes)
                }

            case .rssChannelItemMediaPrice:

                if items?.last?.media?.mediaPrices == nil {
                    items?.last?.media?.mediaPrices = []
                }

                items?.last?.media?.mediaPrices?.append(MediaPrice(attributes: attributes))

            case .rssChannelItemMediaLicense:

                if items?.last?.media?.mediaLicense == nil {
                    items?.last?.media?.mediaLicense = MediaLicence(attributes: attributes)
                }

            case .rssChannelItemMediaSubTitle:

                if items?.last?.media?.mediaSubTitle == nil {
                    items?.last?.media?.mediaSubTitle = MediaSubTitle(attributes: attributes)
                }

            case .rssChannelItemMediaPeerLink:

                if items?.last?.media?.mediaPeerLink == nil {
                    items?.last?.media?.mediaPeerLink = MediaPeerLink(attributes: attributes)
                }

            case .rssChannelItemMediaLocation:

                if items?.last?.media?.mediaLocation == nil {
                    items?.last?.media?.mediaLocation = MediaLocation(attributes: attributes)
                }

            case .rssChannelItemMediaRestriction:

                if items?.last?.media?.mediaRestriction == nil {
                    items?.last?.media?.mediaRestriction = MediaRestriction(attributes: attributes)
                }

            case .rssChannelItemMediaScenes:

                if items?.last?.media?.mediaScenes == nil {
                    items?.last?.media?.mediaScenes = []
                }

            case .rssChannelItemMediaScenesMediaScene:

                if items?.last?.media?.mediaScenes == nil {
                    items?.last?.media?.mediaScenes = []
                }

                items?.last?.media?.mediaScenes?.append(MediaScene())

            case .rssChannelItemMediaGroup:

                if items?.last?.media?.mediaGroup == nil {
                    items?.last?.media?.mediaGroup = MediaGroup()
                }

            case .rssChannelItemMediaGroupMediaCategory:

                if items?.last?.media?.mediaGroup?.mediaCategory == nil {
                    items?.last?.media?.mediaGroup?.mediaCategory = MediaCategory(attributes: attributes)
                }

            case .rssChannelItemMediaGroupMediaCredit:

                if items?.last?.media?.mediaGroup?.mediaCredits == nil {
                    items?.last?.media?.mediaGroup?.mediaCredits = []
                }

                items?.last?.media?.mediaGroup?.mediaCredits?.append(MediaCredit(attributes: attributes))

            case .rssChannelItemMediaGroupMediaRating:

                if items?.last?.media?.mediaGroup?.mediaRating == nil {
                    items?.last?.media?.mediaGroup?.mediaRating = MediaRating(attributes: attributes)
                }

            case .rssChannelItemMediaGroupMediaContent:

                if items?.last?.media?.mediaGroup?.mediaContents == nil {
                    items?.last?.media?.mediaGroup?.mediaContents = []
                }

                items?.last?.media?.mediaGroup?.mediaContents?.append(MediaContent(attributes: attributes))

            default: break
            }

        default: break
        }
    }

    /// Maps the attributes of the specified dictionary for a given `RSSPath`
    /// to the `RSSFeed` model,
    ///
    /// - Parameters:
    ///   - attributes: The attribute dictionary to map to the model.
    ///   - path: The path of feed's element.
    func map(_: [String: String], for path: RDFPath) {
        switch path {
        case .rdfItem:
            if items == nil {
                items = []
            }

            items?.append(RSSFeedItem())

        case
            .rdfChannelSyndicationUpdateBase,
            .rdfChannelSyndicationUpdatePeriod,
            .rdfChannelSyndicationUpdateFrequency:

            if syndication == nil {
                syndication = SyndicationNamespace()
            }

        case
            .rdfChannelDublinCoreTitle,
            .rdfChannelDublinCoreCreator,
            .rdfChannelDublinCoreSubject,
            .rdfChannelDublinCoreDescription,
            .rdfChannelDublinCorePublisher,
            .rdfChannelDublinCoreContributor,
            .rdfChannelDublinCoreDate,
            .rdfChannelDublinCoreType,
            .rdfChannelDublinCoreFormat,
            .rdfChannelDublinCoreIdentifier,
            .rdfChannelDublinCoreSource,
            .rdfChannelDublinCoreLanguage,
            .rdfChannelDublinCoreRelation,
            .rdfChannelDublinCoreCoverage,
            .rdfChannelDublinCoreRights:

            if dublinCore == nil {
                dublinCore = DublinCoreNamespace()
            }

        case
            .rdfItemDublinCoreTitle,
            .rdfItemDublinCoreCreator,
            .rdfItemDublinCoreSubject,
            .rdfItemDublinCoreDescription,
            .rdfItemDublinCorePublisher,
            .rdfItemDublinCoreContributor,
            .rdfItemDublinCoreDate,
            .rdfItemDublinCoreType,
            .rdfItemDublinCoreFormat,
            .rdfItemDublinCoreIdentifier,
            .rdfItemDublinCoreSource,
            .rdfItemDublinCoreLanguage,
            .rdfItemDublinCoreRelation,
            .rdfItemDublinCoreCoverage,
            .rdfItemDublinCoreRights:

            if items?.last?.dublinCore == nil {
                items?.last?.dublinCore = DublinCoreNamespace()
            }

        case .rdfItemContentEncoded:
            if items?.last?.content == nil {
                items?.last?.content = ContentNamespace()
            }

        default: break
        }
    }
}
