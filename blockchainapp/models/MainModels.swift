//
//  MainModels.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Station: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var image: String = ""
	@objc dynamic var sourceURL: String = ""
	@objc dynamic var subscriptionCount: Int = 0
	@objc dynamic var trackCount: Int = 0
	@objc dynamic var lang: String     		= ""
	var tags: List<Tag> = List<Tag>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func uniqString() -> String {
        return "\(id)"
    }
	
	func tracksCount() -> Int64 {
		guard let realm = try? Realm() else {
			return 0
		}
		return Int64(realm.objects(Track.self).filter("station == \(id)").count)
		
	}
	
	convenience init?(json: JSON) {
		if let id = json["Id"].int,
			let name = json["Name"].string,
			let image = json["ImageURL"].string?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
			let subscriptionCount = json["SubscriptionCount"].int,
			let lang = json["Lang"].string{
			
			self.init()
			self.id = id
			self.name = name
			self.image = image
			self.subscriptionCount = subscriptionCount
			self.lang = lang
			if let tags = json["Tags"].array?.map({$0.string}) {
				tags.forEach({ (tag) in
					if let tag = tag {
						let rlmTag = Tag()
						rlmTag.value = tag
						self.tags.append(rlmTag)
					}
				})
			}
			return
		}
		
		return nil
	}
}

class Tag: RealmString {
	
}

class Track: Object {
    @objc dynamic var id: Int               = 0
    @objc dynamic var station: Int          = 0
    @objc dynamic var name: String          = ""
    @objc dynamic var desc: String          = ""
	
    @objc dynamic var image: String         = ""
	@objc dynamic var length: Int64     		= 0
	@objc dynamic var url: String           = ""


	@objc dynamic var likeCount: Int        = 0
	@objc dynamic var reportCount: Int      = 0
	@objc dynamic var listenCount: Int      = 0
	
	@objc dynamic var lang: String     		= ""
	var tags: List<Tag> = List<Tag>()
	


    /**
     * yyyy-mm-ddThh:mm:ss[.mmm]
     */
    @objc dynamic var publishedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func uniqString() -> String {
        return "\(id)"
    }
}
extension Track {
    public func findStationName() -> String? {
		
        return (try? Realm())?.object(ofType: Station.self, forPrimaryKey: station)?.name
    }
    
    public func findChannelImage() -> URL? {
		if let image = (try? Realm())?.object(ofType: Station.self, forPrimaryKey: station)?.image, let url = URL(string: image) {
			return url
		}
		return nil
    }
}

extension Track {
	func audioTrack() -> AudioTrack {
		return PlayerTrack.init(id: self.audiotrackId(), trackURL: URL(string: url)!, name: self.name, author: self.findStationName() ?? "", imageURL: self.image.buildImageURL(), length: self.length)
	}
	
	func audiotrackId() -> String {
		return "\(self.id)"
	}
}
