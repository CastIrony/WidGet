//
//  AtomFeed + mapCharacters.swift
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
    /// Maps the characters in the specified string to the `AtomFeed` model.
    ///
    /// - Parameters:
    ///   - string: The string to map to the model.
    ///   - path: The path of feed's element.
    func map(_ string: String, for path: AtomPath) {
        switch path {
        case .feedTitle: title = title?.appending(string) ?? string
        case .feedSubtitle: subtitle?.value = subtitle?.value?.appending(string) ?? string
        case .feedUpdated: updated = string.toPermissiveDate()
        case .feedAuthorName: authors?.last?.name = authors?.last?.name?.appending(string) ?? string
        case .feedAuthorEmail: authors?.last?.email = authors?.last?.email?.appending(string) ?? string
        case .feedAuthorUri: authors?.last?.uri = authors?.last?.uri?.appending(string) ?? string
        case .feedContributorName: contributors?.last?.name = contributors?.last?.name?.appending(string) ?? string
        case .feedContributorEmail: contributors?.last?.email = contributors?.last?.email?.appending(string) ?? string
        case .feedContributorUri: contributors?.last?.uri = contributors?.last?.uri?.appending(string) ?? string
        case .feedID: id = id?.appending(string) ?? string
        case .feedGenerator: generator?.value = generator?.value?.appending(string) ?? string
        case .feedIcon: icon = icon?.appending(string) ?? string
        case .feedLogo: logo = logo?.appending(string) ?? string
        case .feedRights: rights = rights?.appending(string) ?? string
        case .feedEntryTitle: entries?.last?.title = entries?.last?.title?.appending(string) ?? string
        case .feedEntrySummary: entries?.last?.summary?.value = entries?.last?.summary?.value?.appending(string) ?? string
        case .feedEntryUpdated: entries?.last?.updated = string.toPermissiveDate()
        case .feedEntryID: entries?.last?.id = entries?.last?.id?.appending(string) ?? string
        case .feedEntryContent: entries?.last?.content?.value = entries?.last?.content?.value?.appending(string) ?? string
        case .feedEntryPublished: entries?.last?.published = string.toPermissiveDate()
        case .feedEntrySourceID: entries?.last?.source?.id = entries?.last?.source?.id?.appending(string) ?? string
        case .feedEntrySourceTitle: entries?.last?.source?.title = entries?.last?.source?.title?.appending(string) ?? string
        case .feedEntrySourceUpdated: entries?.last?.source?.updated = string.toPermissiveDate()
        case .feedEntryRights: entries?.last?.rights = entries?.last?.rights?.appending(string) ?? string
        case .feedEntryAuthorName: entries?.last?.authors?.last?.name = entries?.last?.authors?.last?.name?.appending(string) ?? string
        case .feedEntryAuthorEmail: entries?.last?.authors?.last?.email = entries?.last?.authors?.last?.email?.appending(string) ?? string
        case .feedEntryAuthorUri: entries?.last?.authors?.last?.uri = entries?.last?.authors?.last?.uri?.appending(string) ?? string
        case .feedEntryContributorName: entries?.last?.contributors?.last?.name = entries?.last?.contributors?.last?.name?.appending(string) ?? string
        case .feedEntryContributorEmail: entries?.last?.contributors?.last?.email = entries?.last?.contributors?.last?.email?.appending(string) ?? string
        case .feedEntryContributorUri: entries?.last?.contributors?.last?.uri = entries?.last?.contributors?.last?.uri?.appending(string) ?? string
        case .feedEntryMediaThumbnail: entries?.last?.media?.mediaThumbnails?.last?.value = entries?.last?.media?.mediaThumbnails?.last?.value?.appending(string) ?? string
        case .feedEntryMediaLicense: entries?.last?.media?.mediaLicense?.value = entries?.last?.media?.mediaLicense?.value?.appending(string) ?? string
        case .feedEntryMediaRestriction: entries?.last?.media?.mediaRestriction?.value = entries?.last?.media?.mediaRestriction?.value?.appending(string) ?? string
        case .feedEntryMediaCommunityMediaTags: entries?.last?.media?.mediaCommunity?.mediaTags = MediaTag.tagsFrom(string: string)
        case .feedEntryMediaCommentsMediaComment: entries?.last?.media?.mediaComments?.append(string)
        case .feedEntryMediaEmbedMediaParam: entries?.last?.media?.mediaEmbed?.mediaParams?.last?.value = entries?.last?.media?.mediaEmbed?.mediaParams?.last?.value?.appending(string) ?? string
        case .feedEntryMediaGroupMediaCredit: entries?.last?.media?.mediaGroup?.mediaCredits?.last?.value = entries?.last?.media?.mediaGroup?.mediaCredits?.last?.value?.appending(string) ?? string
        case .feedEntryMediaGroupMediaCategory: entries?.last?.media?.mediaGroup?.mediaCategory?.value = entries?.last?.media?.mediaGroup?.mediaCategory?.value?.appending(string) ?? string
        case .feedEntryMediaGroupMediaRating: entries?.last?.media?.mediaGroup?.mediaRating?.value = entries?.last?.media?.mediaGroup?.mediaRating?.value?.appending(string) ?? string
        case .feedEntryMediaResponsesMediaResponse: entries?.last?.media?.mediaResponses?.append(string)
        case .feedEntryMediaBackLinksBackLink: entries?.last?.media?.mediaBackLinks?.append(string)
        case .feedEntryMediaLocationPosition: entries?.last?.media?.mediaLocation?.mapFrom(latLng: string)
        case .feedEntryMediaScenesMediaSceneSceneTitle: entries?.last?.media?.mediaScenes?.last?.sceneTitle = entries?.last?.media?.mediaScenes?.last?.sceneTitle?.appending(string) ?? string
        case .feedEntryMediaScenesMediaSceneSceneDescription: entries?.last?.media?.mediaScenes?.last?.sceneDescription = entries?.last?.media?.mediaScenes?.last?.sceneDescription?.appending(string) ?? string
        case .feedEntryMediaScenesMediaSceneSceneStartTime: entries?.last?.media?.mediaScenes?.last?.sceneStartTime = string.toDuration()
        case .feedEntryMediaScenesMediaSceneSceneEndTime: entries?.last?.media?.mediaScenes?.last?.sceneEndTime = string.toDuration()
        default: break
        }
    }
}
