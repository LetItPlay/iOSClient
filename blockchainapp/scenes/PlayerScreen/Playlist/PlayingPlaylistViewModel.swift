import Foundation

protocol PlayingPlaylistViewDelegate: class {
	func update()
    func reload(index: Int)
    func updateTitles()
}

class PlayingPlaylistViewModel: PlaylistModelDelegate {
	var tracks: [TrackViewModel] = []
	var name: String = ""
	var length: String = ""
	var count: String = ""
    
    weak var delegate: PlayingPlaylistViewDelegate?
	
	func update(track: TrackViewModel, asIndex index: Int) {
		if index > -1 && index < self.tracks.count {
			self.tracks[index] = track
		}
        self.delegate?.reload(index: index)
	}
	
	func reload(tracks: [TrackViewModel], count: String, length: String) {
		self.tracks = tracks
		self.count = count
		self.length = length
        self.delegate?.update()
        self.delegate?.updateTitles()
	}
	
	func re(name: String) {
		self.name = name
        self.delegate?.updateTitles()
	}
}
