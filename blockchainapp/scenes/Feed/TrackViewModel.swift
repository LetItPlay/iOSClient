import Foundation
import RxSwift

enum TrackUpdateFields {
	case listens
	case likes
	case isLiked
	case isPlaying
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
	var isLiked: Bool = false
	var isPlaying: Bool = false
	
	init(track: Track, isPlaying: Bool = false) {
		self.name = track.name
		self.imageURL = track.image
		self.length = track.length.formatTime()
		self.dateString = track.publishedAt.formatString()
        self.description = track.desc
		self.likesCount = Int64(track.likeCount).formatAmount()
		self.listensCount = Int64(track.listenCount).formatAmount()
		self.isLiked = track.isLiked
		
		self.author = track.channel.name
		self.authorImage = track.channel.image
		
		self.isPlaying = isPlaying
	}
	
	init(track: TrackObject, isPlaying: Bool = false, isLiked: Bool = false) {
		self.name = track.name
		self.author = track.findChannelName() ?? ""
		self.authorImage = track.findChannelImage()
		self.imageURL = URL(string: track.image)
		self.length = track.length.formatTime()
		self.likesCount = Int64(track.likeCount).formatAmount()
		self.listensCount = Int64(track.listenCount).formatAmount()
		self.dateString = track.publishedAt.formatString()
        self.description = track.desc
        self.isPlaying = isPlaying
	}
	
	mutating func update(vm: TrackViewModel) {
		self.likesCount = vm.likesCount
		self.listensCount = vm.listensCount
		self.isLiked = vm.isLiked
	}
}
