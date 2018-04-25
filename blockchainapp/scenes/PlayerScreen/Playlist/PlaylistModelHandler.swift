import Foundation

extension PlayerModel: PlaylistEventHandler, PlayerUsingProtocol {
	func selected(index: Int) {
		self.playingIndex = index
		self.reloadTrack()
	}
	
	func morePressed(index: Int) {
        if self.playingIndex > -1 && self.playingIndex < self.tracks.count {
            self.playerDelegate?.showMoreDialog(track: self.tracks[index])
        }
	}
}
