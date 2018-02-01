//
//  MainModels.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

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
	@objc dynamic var coverURL: String     	= ""
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
        return realm?.object(ofType: Station.self, forPrimaryKey: station)?.name
    }
    
    public func findChannelImage() -> URL? {
        return realm?.object(ofType: Station.self, forPrimaryKey: station)?.image.buildImageURL()
    }
}

extension Track {
	func audioTrack() -> AudioTrack {
		return PlayerTrack.init(id: self.audiotrackId(), trackURL: url, name: self.name, author: self.findStationName() ?? "", imageURL: self.image.buildImageURL(), length: self.length)
	}
	
	func audiotrackId() -> String {
		return "\(self.id)"
	}
}
