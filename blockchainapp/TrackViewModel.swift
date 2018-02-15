import Foundation
import RxSwift

enum TrackUpdateFields {
	case listens
	case likes
	case isLiked
	case isPlaying
}

protocol TrackViewModelProtocol {
	var name: Variable<String> {get}
	var author: Variable<String> {get}
	var authorImage: Variable<URL?> {get}
	var imageURL: Variable<URL?> {get}
	var length: Variable<String> {get}
	var likesCount: Variable<String> {get}
	var listensCount: Variable<String> {get}
	var dateString: Variable<String> {get}
	var description: Variable<String> {get}
	var isLiked: Variable<Bool> {get}
	var isPlaying: Variable<Bool> {get}
}

struct TrackViewModel {
	var name: String = ""
	var author: String = ""
	var authorImage: URL? = nil
	var imageURL: URL? = nil
	var length: String = ""
	var likesCount: String = ""
	var listensCount: String = ""
	var dateString: String = ""
    var description: String = ""
	var isLiked: Bool = true
	var isPlaying: Bool = false
	
	init(track: Track1, isPlaying: Bool = false, isLiked: Bool = false) {
		self.name = track.name
		self.imageURL = track.image
		self.length = track.length.formatTime()
		self.likesCount = Int64(track.likeCount).formatAmount()
		self.listensCount = Int64(track.listenCount).formatAmount()
		self.dateString = track.publishedAt.formatString()
        self.description = track.desc
		
		self.isPlaying = isPlaying
		self.isLiked = isLiked
	}
	
	init(track: Track, isPlaying: Bool = false, isLiked: Bool = false) {
		self.name = track.name
		self.author = track.findStationName() ?? ""
		self.authorImage = track.findChannelImage()
		self.imageURL = URL(string: track.image)
		self.length = track.length.formatTime()
		self.likesCount = Int64(track.likeCount).formatAmount()
		self.listensCount = Int64(track.listenCount).formatAmount()
		self.dateString = track.publishedAt.formatString()
	}
	
	mutating func update(fields: [TrackUpdateFields: Any]) {
		for key in fields.keys {
			switch key {
			case .isLiked:
				if let value = fields[key] as? Bool {
					self.isLiked = value
				}
			case .isPlaying:
				if let value = fields[key] as? Bool {
					self.isPlaying = value
				}
			case .listens:
				if let value = fields[key] as? String {
					self.listensCount = value
				}
			case .likes:
				if let value = fields[key] as? String {
					self.likesCount = value
				}
			}
		}
	}
}
