import Foundation
import RealmSwift
import SwiftyJSON


struct Track1 {
	static let formatter: DateFormatter = {
		let form = DateFormatter()
		form.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return form
	}()
	
	var id: Int					= 0
	var name: String			= ""
	var desc: String			= ""
	var publishedAt: Date		= Date()
	
	var image: URL?
	var length: Int64			= 0
	var url: URL?
	
	var stationId: Int			= 0
	
	var likeCount: Int			= 0
	var reportCount: Int		= 0
	var listenCount: Int		= 0
	
	var tags: [String]			= []
	
	var lang: String			= Language.ru.rawValue
	
	init?(json: JSON) {
		if 	let stationId = json["StationID"].int,
			let idInt = json["Id"].int,
			let title = json["Title"].string,
			let audioURL = json["AudioURL"].string?.url(),
			let publishedAtString = json["PublishedAt"].string,
			let publishedAt = Track1.formatter.date(from: publishedAtString),
			let lang = json["Lang"].string {
			
			self.id = idInt
			self.name = title
			self.url = audioURL
			
			self.publishedAt = publishedAt
			
			self.lang = lang
			self.stationId = stationId
			
			self.tags = json["Tags"].array?.map({$0.string}).filter({$0 != nil}).map({$0!}) ?? []
			
			self.length = json["TotalLengthInSeconds"].int64 ?? 0
			self.desc = json["Description"].string ?? ""
			self.image = json["CoverURL"].string?.url()
			
			self.likeCount = json["LikeCount"].int ?? 0
			self.listenCount = json["ListenCount"].int ?? 0
			self.reportCount = json["ReportsCount"].int ?? 0
			
			return
		}
		
		return nil
	}
	
	func audioTrack(author: String) -> AudioTrack {
		return PlayerTrack.init(id: self.idString(), trackURL: self.url!, name: self.name, author: author, imageURL: self.image, length: self.length)
	}
	
	func idString() -> String {
		return "\(id)"
	}
}


class Track: Object {
	@objc dynamic var id: Int               = 0
	@objc dynamic var station: Int          = 0
	@objc dynamic var name: String          = ""
	@objc dynamic var desc: String          = ""
	
	@objc dynamic var image: String         = ""
	@objc dynamic var length: Int64     	= 0
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
	
	convenience init?(json: JSON) {
		if let idInt = json["Id"].int,
			let title = json["Title"].string,
			let audioURL = json["AudioURL"].string,
			let publishedAt = json["PublishedAt"].string,
			let lang = json["Lang"].string,
			let station = json["StationID"].int {
			
			self.init()
			self.id = idInt
			self.name = title
			self.lang = lang
			self.url = audioURL
			self.station = station
			
			self.length = json["TotalLengthInSeconds"].int64 ?? 0
			self.desc = json["Description"].string ?? ""
			self.image = json["CoverURL"].string ?? ""
			
			self.likeCount = json["LikeCount"].int ?? 0
			self.listenCount = json["ListenCount"].int ?? 0
			
			
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
		return PlayerTrack.init(id: self.audiotrackId(), trackURL: URL(string: url)!, name: self.name, author: self.findStationName() ?? "", imageURL: self.image.buildImageURL(), length: self.length)
	}
	
	func audiotrackId() -> String {
		return "\(self.id)"
	}
}
