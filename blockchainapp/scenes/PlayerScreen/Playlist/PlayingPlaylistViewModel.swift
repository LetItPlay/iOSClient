import Foundation

protocol PlaylistViewDelegate: class {
	
}

class PlayingPlaylistViewModel: PlaylistModelDelegate {
	var tracks: [TrackViewModel] = []
	var name: String = ""
	var length: String = ""
	var count: String = ""
}
