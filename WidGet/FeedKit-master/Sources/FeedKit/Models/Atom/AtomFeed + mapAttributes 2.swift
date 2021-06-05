//
//  AtomFeed + mapAttributes.swift
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

extension AtomFeed {
    /// Maps the attributes of the specified dictionary for a given `AtomPath`
    /// to the `AtomFeed` model
    ///
    /// - Parameters:
    ///   - attributes: The attribute dictionary to map to the model.
    ///   - path: The path of feed's element.
    func map(_ attributes: [String: String], for path: AtomPath) {
        switch path {
        case .feedSubtitle:

            if subtitle == nil {
                subtitle = AtomFeedSubtitle(attributes: attributes)
            }

        case .feedLink:

            if links == nil {
                links = []
            }

            links?.append(AtomFeedLink(attributes: attributes))

        case .feedCategory:

            if categories == nil {
                categories = []
            }

            categories?.append(AtomFeedCategory(attributes: attributes))

        case .feedAuthor:

            if authors == nil {
                authors = []
            }

            authors?.append(AtomFeedAuthor())

        case .feedContributor:

            if contributors == nil {
                contributors = []
            }

            contributors?.append(AtomFeedContributor())

        case .feedGenerator:

            if generator == nil {
                generator = AtomFeedGenerator(attributes: attributes)
            }

        case .feedEntry:

            if entries == nil {
                entries = []
            }

            entries?.append(AtomFeedEntry())

        case .feedEntrySummary:

            if entries?.last?.summary == nil {
                entries?.last?.summary = AtomFeedEntrySummary(attributes: attributes)
            }

        case .feedEntryAuthor:

            if entries?.last?.authors == nil {
                entries?.last?.authors = []
            }

            entries?.last?.authors?.append(AtomFeedEntryAuthor())

        case .feedEntryContributor:

            if entries?.last?.contributors == nil {
                entries?.last?.contributors = []
            }

            entries?.last?.contributors?.append(AtomFeedEntryContributor())

        case .feedEntryLink:

            if entries?.last?.links == nil {
                entries?.last?.links = []
            }

            entries?.last?.links?.append(AtomFeedEntryLink(attributes: attributes))

        case .feedEntryCategory:

            if entries?.last?.categories == nil {
                entries?.last?.categories = []
            }

            entries?.last?.categories?.append(AtomFeedEntryCategory(attributes: attributes))

        case .feedEntryContent:

            if entries?.last?.content == nil {
                entries?.last?.content = AtomFeedEntryContent(attributes: attributes)
            }

        case .feedEntrySource:

            if entries?.last?.source == nil {
                entries?.last?.source = AtomFeedEntrySource()
            }

            // MARK: Media

        case
            .feedEntryMediaThumbnail,
            .feedEntryMediaContent,
            .feedEntryMediaCommunity,
            .feedEntryMediaCommunityMediaStarRating,
            .feedEntryMediaCommunityMediaStatistics,
            .feedEntryMediaCommunityMediaTags,
            .feedEntryMediaComments,
            .feedEntryMediaCommentsMediaComment,
            .feedEntryMediaEmbed,
            .feedEntryMediaEmbedMediaParam,
            .feedEntryMediaResponses,
            .feedEntryMediaResponsesMediaResponse,
            .feedEntryMediaBackLinks,
            .feedEntryMediaBackLinksBackLink,
            .feedEntryMediaStatus,
            .feedEntryMediaPrice,
            .feedEntryMediaLicense,
            .feedEntryMediaSubTitle,
            .feedEntryMediaPeerLink,
            .feedEntryMediaLocation,
            .feedEntryMediaLocationPosition,
            .feedEntryMediaRestriction,
            .feedEntryMediaScenes,
            .feedEntryMediaScenesMediaScene,
            .feedEntryMediaGroup,
            .feedEntryMediaGroupMediaCategory,
            .feedEntryMediaGroupMediaCredit,
            .feedEntryMediaGroupMediaThumbnail,
            .feedEntryMediaGroupMediaRating,
            .feedEntryMediaGroupMediaContent:

            if entries?.last?.media == nil {
                entries?.last?.media = MediaNamespace()
            }

            switch path {
            case .feedEntryMediaThumbnail:

                if entries?.last?.media?.mediaThumbnails == nil {
                    entries?.last?.media?.mediaThumbnails = []
                }

                entries?.last?.media?.mediaThumbnails?.append(MediaThumbnail(attributes: attributes))

            case .feedEntryMediaContent:

                if entries?.last?.media?.mediaContents == nil {
                    entries?.last?.media?.mediaContents = []
                }

                entries?.last?.media?.mediaContents?.append(MediaContent(attributes: attributes))

            case .feedEntryMediaCommunity:

                if entries?.last?.media?.mediaCommunity == nil {
                    entries?.last?.media?.mediaCommunity = MediaCommunity()
                }

            case .feedEntryMediaCommunityMediaStarRating:

                if entries?.last?.media?.mediaCommunity?.mediaStarRating == nil {
                    entries?.last?.media?.mediaCommunity?.mediaStarRating = MediaStarRating(attributes: attributes)
                }

            case .feedEntryMediaCommunityMediaStatistics:

                if entries?.last?.media?.mediaCommunity?.mediaStatistics == nil {
                    entries?.last?.media?.mediaCommunity?.mediaStatistics = MediaStatistics(attributes: attributes)
                }

            case .feedEntryMediaCommunityMediaTags:

                if entries?.last?.media?.mediaCommunity?.mediaTags == nil {
                    entries?.last?.media?.mediaCommunity?.mediaTags = []
                }

            case .feedEntryMediaComments:

                if entries?.last?.media?.mediaComments == nil {
                    entries?.last?.media?.mediaComments = []
                }

            case .feedEntryMediaEmbed:

                if entries?.last?.media?.mediaEmbed == nil {
                    entries?.last?.media?.mediaEmbed = MediaEmbed(attributes: attributes)
                }

            case .feedEntryMediaEmbedMediaParam:

                if entries?.last?.media?.mediaEmbed?.mediaParams == nil {
                    entries?.last?.media?.mediaEmbed?.mediaParams = []
                }

                entries?.last?.media?.mediaEmbed?.mediaParams?.append(MediaParam(attributes: attributes))

            case .feedEntryMediaResponses:

                if entries?.last?.media?.mediaResponses == nil {
                    entries?.last?.media?.mediaResponses = []
                }

            case .feedEntryMediaBackLinks:

                if entries?.last?.media?.mediaBackLinks == nil {
                    entries?.last?.media?.mediaBackLinks = []
                }

            case .feedEntryMediaStatus:

                if entries?.last?.media?.mediaStatus == nil {
                    entries?.last?.media?.mediaStatus = MediaStatus(attributes: attributes)
                }

            case .feedEntryMediaPrice:

                if entries?.last?.media?.mediaPrices == nil {
                    entries?.last?.media?.mediaPrices = []
                }

                entries?.last?.media?.mediaPrices?.append(MediaPrice(attributes: attributes))

            case .feedEntryMediaLicense:

                if entries?.last?.media?.mediaLicense == nil {
                    entries?.last?.media?.mediaLicense = MediaLicence(attributes: attributes)
                }

            case .feedEntryMediaSubTitle:

                if entries?.last?.media?.mediaSubTitle == nil {
                    entries?.last?.media?.mediaSubTitle = MediaSubTitle(attributes: attributes)
                }

            case .feedEntryMediaPeerLink:

                if entries?.last?.media?.mediaPeerLink == nil {
                    entries?.last?.media?.mediaPeerLink = MediaPeerLink(attributes: attributes)
                }

            case .feedEntryMediaLocation:

                if entries?.last?.media?.mediaLocation == nil {
                    entries?.last?.media?.mediaLocation = MediaLocation(attributes: attributes)
                }

            case .feedEntryMediaRestriction:

                if entries?.last?.media?.mediaRestriction == nil {
                    entries?.last?.media?.mediaRestriction = MediaRestriction(attributes: attributes)
                }

            case .feedEntryMediaScenes:

                if entries?.last?.media?.mediaScenes == nil {
                    entries?.last?.media?.mediaScenes = []
                }

            case .feedEntryMediaScenesMediaScene:

                if entries?.last?.media?.mediaScenes == nil {
                    entries?.last?.media?.mediaScenes = []
                }

                entries?.last?.media?.mediaScenes?.append(MediaScene())

            case .feedEntryMediaGroup:

                if entries?.last?.media?.mediaGroup == nil {
                    entries?.last?.media?.mediaGroup = MediaGroup()
                }

            case .feedEntryMediaGroupMediaCategory:

                if entries?.last?.media?.mediaGroup?.mediaCategory == nil {
                    entries?.last?.media?.mediaGroup?.mediaCategory = MediaCategory(attributes: attributes)
                }

            case .feedEntryMediaGroupMediaCredit:

                if entries?.last?.media?.mediaGroup?.mediaCredits == nil {
                    entries?.last?.media?.mediaGroup?.mediaCredits = []
                }

                entries?.last?.media?.mediaGroup?.mediaCredits?.append(MediaCredit(attributes: attributes))

            case .feedEntryMediaGroupMediaRating:

                if entries?.last?.media?.mediaGroup?.mediaRating == nil {
                    entries?.last?.media?.mediaGroup?.mediaRating = MediaRating(attributes: attributes)
                }

            case .feedEntryMediaGroupMediaThumbnail:

                if entries?.last?.media?.mediaGroup?.mediaThumbnail == nil {
                    entries?.last?.media?.mediaGroup?.mediaThumbnail = MediaThumbnail(attributes: attributes)
                }

            case .feedEntryMediaGroupMediaContent:

                if entries?.last?.media?.mediaGroup?.mediaContents == nil {
                    entries?.last?.media?.mediaGroup?.mediaContents = []
                }

                entries?.last?.media?.mediaGroup?.mediaContents?.append(MediaContent(attributes: attributes))

            default: break
            }

        default: break
        }
    }
}
