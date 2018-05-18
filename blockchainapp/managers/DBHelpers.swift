//
//  DBHelpers.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 02/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DBManager {
    
    static let shared = DBManager()
    
    func track(byId: Int) -> TrackObject? {
        let realm = try! Realm()
        return realm.object(ofType: TrackObject.self, forPrimaryKey: byId)
    }
    
	func addOrUpdateChannel(inRealm: Realm, id: Int, name: String, image: String, subscriptionCount: Int, tags: [String?]?, lang: String) {
        if let channel = inRealm.object(ofType: ChannelObject.self, forPrimaryKey: id) {
            _ = updateIfNeeded(property: &channel.name, new: name)
            _ = updateIfNeeded(property: &channel.image, new: image.buildImageURL()?.absoluteString ?? "")
            _ = updateIfNeeded(property: &channel.subscriptionCount, new: subscriptionCount)
			_ = updateIfNeeded(property: &channel.lang, new: lang)
			_ = updateIfNeeded(property: &channel.trackCount, new: Int64(inRealm.objects(TrackObject.self).filter("station == \(id)").count))
			if let tags = tags {
				tags.forEach({ (tag) in
					if let tagString = tag, !channel.tags.contains(where: {$0.value == tagString}) {
						let tag = Tag.init()
						tag.value = tagString
						let rlmTag = inRealm.create(Tag.self, value: tag, update: true)
						channel.tags.append(rlmTag)
					}
				})
			}
        } else {
            let newStat = ChannelObject()
            newStat.id = id
            newStat.name = name
            newStat.image = image.buildImageURL()?.absoluteString ?? ""
            newStat.subscriptionCount = subscriptionCount
			if let tags = tags {
				tags.forEach({ (tag) in
					if let tagString = tag{
						let tag = Tag.init()
						tag.value = tagString
						let rlmTag = inRealm.create(Tag.self, value: tag, update: true)
						newStat.tags.append(rlmTag)
					}
				})
			}
			newStat.lang = lang
			newStat.trackCount = Int64(inRealm.objects(TrackObject.self).filter("station == \(id)").count)
			
            
            inRealm.add(newStat)
        }
    }
    
	func addOrUpdateTrack(inRealm: Realm, id: Int, channel: Int, name: String, url: String, length: Int64, description: String, coverURL: String, likeCount: Int, reportCount: Int, listenCount: Int, tags: [String?]?, publishDate: String, lang: String) {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let description = description == "" ? LocalizedStrings.EmptyMessage.noDescription : description
		
        if let track = inRealm.object(ofType: TrackObject.self, forPrimaryKey: id) {
            var changeCounter = 0
            changeCounter += updateIfNeeded(property: &track.channel, new: channel)
            changeCounter += updateIfNeeded(property: &track.name, new: name)
            changeCounter += updateIfNeeded(property: &track.desc, new: description)
            changeCounter += updateIfNeeded(property: &track.likeCount, new: likeCount)
            changeCounter += updateIfNeeded(property: &track.reportCount, new: reportCount)
            changeCounter += updateIfNeeded(property: &track.listenCount, new: listenCount)
			changeCounter += updateIfNeeded(property: &track.url, new: url.buildImageURL()?.absoluteString ?? "")
			changeCounter += updateIfNeeded(property: &track.image, new: coverURL.buildImageURL()?.absoluteString ?? "")
			changeCounter += updateIfNeeded(property: &track.length, new: length)

			changeCounter += updateIfNeeded(property: &track.lang, new: lang)
			
			if let tags = tags {
				tags.forEach({ (tag) in
					if let tagString = tag, !track.tags.contains(where: {$0.value == tagString}) {
						let tag = Tag.init()
						tag.value = tagString
						let rlmTag = inRealm.create(Tag.self, value: tag, update: true)
						track.tags.append(rlmTag)
						changeCounter += 1
					}
				})
			}
			
            changeCounter += updateIfNeeded(property: &track.publishedAt, new: formatter.date(from: publishDate) ?? Date().addingTimeInterval(-60*60*24*30))
            
            debugPrint("track \(id) counter=\(changeCounter)")
        } else {
            let newTrack = TrackObject()
            newTrack.id = id
            newTrack.channel = channel
            newTrack.name = name
            newTrack.url  = url.buildImageURL()?.absoluteString ?? ""
            newTrack.desc = description
            newTrack.likeCount = likeCount
            newTrack.reportCount = reportCount
            newTrack.listenCount = listenCount
			newTrack.length = length
            newTrack.image = coverURL.buildImageURL()?.absoluteString ?? ""
			newTrack.lang = lang
			if let tags = tags {
				tags.forEach({ (tag) in
					if let tagString = tag {
						let tag = Tag.init()
						tag.value = tagString
						let rlmTag = inRealm.create(Tag.self, value: tag, update: true)
						newTrack.tags.append(rlmTag)
					}
				})
			}
			newTrack.publishedAt = formatter.date(from: publishDate) ?? Date().addingTimeInterval(-60*60*24*30)
			newTrack.lang = lang
            
            inRealm.add(newTrack)
        }
        
    }
    
    private func updateIfNeeded<T: Equatable>(property: inout T, new: T) -> Int {
        if property != new {
            property = new
            
            return 1
        }
        
        return 0
    }
    
}

extension DBManager {
    public func track(fromJSON: JSON, realm: Realm) {
        if let idInt = fromJSON["Id"].int,
			let title = fromJSON["Title"].string,
			let audioURL = fromJSON["AudioURL"].string,
			let publishedAt = fromJSON["PublishedAt"].string,
			let lang = fromJSON["Lang"].string,
			let channel = fromJSON["StationID"].int {
			
			addOrUpdateTrack(inRealm: realm,
							 id: idInt,
							 channel: channel,
							 name: title,
							 url: audioURL,
							 length: fromJSON["TotalLengthInSeconds"].int64 ?? 0,
							 description: fromJSON["Description"].string ?? LocalizedStrings.EmptyMessage.noDescription,
							 coverURL: fromJSON["CoverURL"].string ?? "",
							 likeCount: fromJSON["LikeCount"].int ?? 0,
							 reportCount: 0,
							 listenCount: fromJSON["ListenCount"].int ?? 0,
							 tags: fromJSON["Tags"].array?.map({$0.string}),
							 publishDate: publishedAt,
							 lang: lang)
        } else if let idInt = fromJSON["id"].int {
            addOrUpdateTrack(inRealm: realm,
                             id: idInt,
                             channel: fromJSON["station"].int ?? 0,
                             name: fromJSON["name"].string ?? "",
                             url: fromJSON["audio_file"]["file"].string ?? "",
                             length: fromJSON["audio_file"]["length_seconds"].int64 ?? 0,
                             description: fromJSON["description"].string ?? LocalizedStrings.EmptyMessage.noDescription,
                             coverURL: fromJSON["image"].string ?? "",
                             likeCount: fromJSON["like_count"].int ?? 0,
                             reportCount: 0,
                             listenCount: fromJSON["listen_count"].int ?? 0,
                             tags: fromJSON["tags"].string?.components(separatedBy: ","),
                             publishDate: fromJSON["published_at"].string ?? "",
                             lang: fromJSON["lang"].string ?? "ru")
        }
    }
}
