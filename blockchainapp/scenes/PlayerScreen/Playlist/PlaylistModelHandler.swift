import Foundation

extension PlayerModel: PlaylistEventHandler, PlayerUsingProtocol {
	func showOthers(index: Int) {
        if self.playingIndex > -1 && self.playingIndex < self.tracks.count {
            let track = self.tracks[index]
            self.playerDelegate?.showMoreDialog(track: track.sharedInfo())
        }
	}
}
