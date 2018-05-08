import Foundation
import SwiftyJSON
import RealmSwift

typealias ObjectInfo = (id: Int, name: String, image: URL?)

struct Channel: LIPModel, Hashable {
	var id: Int = 0
	var name: String = ""
	var image: URL?
	var sourceURL: URL?
	var subscriptionCount: Int	= 0
	var trackCount: Int			= 0
	var descr: String			= ""
	
    var isSubscribed: Bool      = false
	var isReported: Bool		= false
    
	var lang: String			= UserSettings.languages[2].identifier
	var tags: [String]			= []
	
	init?(json: JSON) {
		if let id = json["Id"].int,
		   let name = json["Name"].string,
		   let subscriptionCount = json["SubscriptionCount"].int,
			let lang = json["Lang"].string{
			
			self.id = id
			self.name = name
			self.image = json["ImageURL"].string?.url()
			self.subscriptionCount = subscriptionCount
			self.sourceURL = json["YouTubeURL"].string?.url()
			self.descr = json["Description"].string ?? ""
			self.lang = lang
			self.tags = json["Tags"].array?.map({$0.string}).filter({$0 != nil}).map({$0!}) ?? []
            self.isSubscribed = json["followed"].bool ?? false
			self.isReported = json["reported"].bool ?? false
			return
		}
		
		return nil
	}
	
	fileprivate init() {
		
	}
	
	static func ==(f: Channel, s: Channel) -> Bool {
		return f.id == s.id
	}
	
	var hashValue: Int {
		return self.id
	}
    
    func sharedInfo() -> ShareInfo {
        return ShareInfo(text: self.name, url: RequestManager.server + "/tracks?channel=/\(self.id)", image: try! UIImage(data: Data(contentsOf: (self.image)!))!)
    }
}

class ChannelObject: Object {
	@objc dynamic var id: Int = 0
	@objc dynamic var name: String = ""
	@objc dynamic var image: String = ""
	@objc dynamic var sourceURL: String = ""
	@objc dynamic var subscriptionCount: Int = 0
	@objc dynamic var trackCount: Int64 = 0
	@objc dynamic var lang: String     		= ""
	var tags: List<Tag> = List<Tag>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func uniqString() -> String {
		return "\(id)"
	}
	
	func plain() -> Channel {
		var channel = Channel.init()
		channel.id = self.id
		channel.name = self.name
		channel.image = URL(string: self.image)
		channel.sourceURL = URL(string: self.sourceURL)
		channel.subscriptionCount = self.subscriptionCount
		channel.trackCount = Int(self.trackCount)
		channel.lang = self.lang
		channel.tags = self.tags.map({$0.value})
		
		return channel
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
