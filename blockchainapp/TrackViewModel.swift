import Foundation

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
	var liked: Bool = true
	var isPlaying: Bool = false
	
	init(track: Track, isPlaying: Bool = false, isLiked: Bool = false) {
		self.name = track.name
		self.author = track.findStationName() ?? ""
		self.authorImage = track.findChannelImage()
		self.imageURL = URL(string: track.image)
		self.length = track.length.formatTime()
		self.likesCount = Int64(track.likeCount).formatAmount()
		self.listensCount = Int64(track.listenCount).formatAmount()
		self.dateString = track.publishedAt.formatString()
        self.description = track.desc
	}
}
