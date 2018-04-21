import Foundation

protocol PlayingPlaylistViewDelegate: class {
	func update()
}

class PlayingPlaylistViewModel: PlaylistModelDelegate {
	var tracks: [TrackViewModel] = []
	var name: String = ""
	var length: String = ""
	var count: String = ""
	
	func update(track: TrackViewModel, asIndex index: Int) {
		if index > 0 && index < self.tracks.count {
			self.tracks[index] = track
		}
	}
	
	func reload(tracks: [TrackViewModel], count: String, length: String) {
		self.tracks = tracks
		self.count = count
		self.length = length
	}
	
	func re(name: String) {
		self.name = name
	}
}
