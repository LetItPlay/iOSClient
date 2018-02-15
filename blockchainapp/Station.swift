import Foundation
import SwiftyJSON
import RealmSwift

typealias ObjectInfo = (id: Int, name: String, image: URL?)

struct Station1 {
	var id: Int					= 0
	var name: String			= ""
	var image: URL?
	var sourceURL: URL?
	var subscriptionCount: Int	= 0
	var trackCount: Int			= 0
	var descr: String			= ""
	
	var lang: String			= Language.ru.rawValue
	var tags: [String]			= []
	
	init?(json: JSON) {
		if let id = json["Id"].int,
			let name = json["Name"].string,
			let image = json["ImageURL"].string?.url(),
			let subscriptionCount = json["SubscriptionCount"].int,
			let lang = json["Lang"].string{
			
			self.id = id
			self.name = name
			self.image = image
			self.subscriptionCount = subscriptionCount
			self.sourceURL = json["YouTubeURL"].string?.url()
			self.descr = json["Description"].string ?? ""
			self.lang = lang
			self.tags = json["Tags"].array?.map({$0.string}).filter({$0 != nil}).map({$0!}) ?? []
			return
		}
		
		return nil
	}
}

class Station: Object {
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
