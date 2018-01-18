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
    @objc dynamic var subscriptionCount: Int = 0
    @objc dynamic var tagString: String = ""
	@objc dynamic var lang: String     		= ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func uniqString() -> String {
        return "\(id)"
    }
    
    func getTags() -> [String] {
        return tagString.split(separator: ",").map{ String($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }
}

class Track: Object {
    @objc dynamic var id: Int               = 0
    @objc dynamic var station: Int          = 0
    @objc dynamic var audiofile: Audiofile? = nil
    @objc dynamic var name: String          = ""
    @objc dynamic var url: String           = ""
    @objc dynamic var desc: String          = ""
    @objc dynamic var image: String         = ""
    @objc dynamic var likeCount: Int        = 0
    @objc dynamic var reportCount: Int      = 0
    @objc dynamic var listenCount: Int      = 0
    @objc dynamic var tagString: String     = ""
	@objc dynamic var lang: String     		= ""

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
    
    func getTags() -> [String] {
        return tagString.split(separator: ",").map{ String($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
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
		return AudioTrack.init(id: "\(self.id)", trackURL: (self.audiofile?.file.buildImageURL())!, name: self.name, author: self.findStationName() ?? "", imageURL: self.image.buildImageURL(), length: self.audiofile?.lengthSeconds ?? 0)
	}
}

class Audiofile: Object {
    @objc dynamic var file: String = ""
    @objc dynamic var lengthSeconds: Int64 = 0
    @objc dynamic var sizeBytes: Int64 = 0
}
