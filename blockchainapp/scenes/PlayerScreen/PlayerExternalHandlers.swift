import Foundation

protocol PlayerProtocol {
	func loadPlaylist(name: String, tracks: [Track])
	func trackSelected(playlistName: String, id: Int) -> Bool
	func add(track: Track, inBeginning: Bool)
}

protocol PlaylistProtocol {
	func remove(index: Int)
	func clearAll()
	func reload(tracks: [Track])
}

extension PlayerModel: PlaylistProtocol {
	func reload(tracks: [Track]) {
		self.tracks = tracks
		//TODO: Update playlist
	}
	
	func remove(index: Int) {
		if playingIndex == index {
			let oldTrackCount = self.tracks.count
			self.tracks.remove(at: index)
			if playingIndex == oldTrackCount - 1 {
				self.playingIndex = index - 1
				self.player.make(command: .pause)
			}
			self.reloadTrack()
		}
	}
	
	func clearAll() {
		self.tracks.removeAll()
		self.player.make(command: .pause)
	}
}

extension PlayerModel: PlayerProtocol {
	func loadPlaylist(name: String, tracks: [Track]) {
		self.tracks = tracks
		self.playlistName = name
	}
	
	func add(track: Track, inBeginning: Bool) {
		if !self.tracks.contains(where: {$0.id == track.id}) {
			if inBeginning {
				self.tracks.insert(track, at: self.playingIndex + 1)
			} else {
				self.tracks.append(track)
			}
			// TODO: Update playlist
		}
	}
	
	func trackSelected(playlistName: String, id: Int) -> Bool {
		guard let index = self.tracks.index(where: {$0.id == id}),
			self.playlistName == playlistName else {
				return false
		}
		if self.playingIndex == index {
			self.execute(event: .plause)
		} else {
			self.playingIndex = index
			self.reloadTrack()
		}
		return true
	}
}
