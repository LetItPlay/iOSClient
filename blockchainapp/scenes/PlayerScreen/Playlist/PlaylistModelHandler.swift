import Foundation

extension PlayerModel: PlaylistEventHandler, PlayerUsingProtocol {
	func selected(index: Int) {
		self.playingIndex = index
		self.reloadTrack()
	}
	
	func morePressed(index: Int) {
		
	}
}
