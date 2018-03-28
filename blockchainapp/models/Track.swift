import Foundation
import RealmSwift
import SwiftyJSON

typealias ChannelInfo = (id: Int, name: String, image: URL?)

struct Track: LIPModel {
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
	
	var channel: ChannelInfo!
	
	var likeCount: Int			= 0
	var reportCount: Int		= 0
	var listenCount: Int		= 0
	
	var tags: [String]			= []
	
	var lang: String			= Language.ru.rawValue
	
	var isLiked: Bool			= false
	
	init?(json: JSON) {
		if 	let channelId = json["station"]["Id"].int,
			  let channelName = json["station"]["Name"].string,
			  let idInt = json["Id"].int,
			  let title = json["Title"].string,
			  let audioURL = json["AudioURL"].string?.url(),
			  let publishedAtString = json["PublishedAt"].string,
			  let publishedAt = Track.formatter.date(from: publishedAtString),
			  let lang = json["Lang"].string {
			self.id = idInt
			self.name = title
			self.url = audioURL
			
			self.publishedAt = publishedAt
			
			self.lang = lang
			self.channel = ChannelInfo(id: channelId, name: channelName, image: json["station"]["ImageURL"].string?.url())
			
			self.tags = json["Tags"].array?.map({$0.string}).filter({$0 != nil}).map({$0!}) ?? []
			
			self.length = json["TotalLengthInSeconds"].int64 ?? 0
			self.desc = json["Description"].string ?? ""
			self.image = json["CoverURL"].string?.url()
			
			self.likeCount = json["LikeCount"].int ?? 0
			self.listenCount = json["ListenCount"].int ?? 0
			self.reportCount = json["ReportsCount"].int ?? 0
			
			return
		}
        if let channelId = json["StationID"].int,
            let idInt = json["Id"].int,
            let title = json["Title"].string,
            let audioURL = json["AudioURL"].string?.url(),
            let publishedAtString = json["PublishedAt"].string,
            let publishedAt = Track.formatter.date(from: publishedAtString),
            let lang = json["Lang"].string {
            self.id = idInt
            self.name = title
            self.url = audioURL
            
            self.publishedAt = publishedAt
            
            self.lang = lang
            
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
	
	func audioTrack() -> AudioTrack {
		return PlayerTrack.init(id: self.id, trackURL: self.url!, name: self.name, author: self.channel.name, imageURL: self.image, length: self.length)
	}
	
	func idString() -> String {
		return "\(id)"
	}
}


class TrackObject: Object {
	@objc dynamic var id: Int               = 0
	@objc dynamic var channel: Int          = 0
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
			let channel = json["StationID"].int {
			
			self.init()
			self.id = idInt
			self.name = title
			self.lang = lang
			self.url = audioURL
			self.channel = channel
			
			self.length = json["TotalLengthInSeconds"].int64 ?? 0
			self.desc = json["Description"].string ?? ""
			self.image = json["CoverURL"].string ?? ""
			
			self.likeCount = json["LikeCount"].int ?? 0
			self.listenCount = json["ListenCount"].int ?? 0
			self.publishedAt = Track.formatter.date(from: publishedAt) ?? Date()
			
			
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
	
	convenience init(track: Track) {
		self.init()
		self.id = track.id
		self.name = track.name
		self.channel = track.channel.id
		self.lang = track.lang
		self.url = track.url?.absoluteString ?? ""
		self.length = track.length
		self.desc = track.desc
		self.image = track.image?.absoluteString ?? ""
		self.likeCount = track.likeCount
		self.listenCount = track.listenCount
		track.tags.forEach { (tag) in
			let tagO = Tag()
			tagO.value = tag
			self.tags.append(tagO)
		}
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func uniqString() -> String {
		return "\(id)"
	}
}
extension TrackObject {
	public func findChannelName() -> String? {
		return (try? Realm())?.object(ofType: ChannelObject.self, forPrimaryKey: channel)?.name
	}
	
	public func findChannelImage() -> URL? {
		return (try? Realm())?.object(ofType: ChannelObject.self, forPrimaryKey: channel)?.image.buildImageURL()
	}
}

extension TrackObject {
	func audioTrack() -> AudioTrack {
		return PlayerTrack.init(id: self.id, trackURL: URL(string: url)!, name: self.name, author: self.findChannelName() ?? "", imageURL: self.image.buildImageURL(), length: self.length)
	}
	
	func audiotrackId() -> String {
		return "\(self.id)"
	}
}
