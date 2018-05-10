import Foundation

extension PlayerModel: PlaylistEventHandler, PlayerUsingProtocol {
	func selected(index: Int) {
		self.playingIndex = index
		self.reloadTrack()
	}
	
	func showOthers(index: Int) {
        if self.playingIndex > -1 && self.playingIndex < self.tracks.count {
            let track = self.tracks[index]
            self.playerDelegate?.showMoreDialog(track: track.sharedInfo(), trackID: track.id)
        }
	}
}
