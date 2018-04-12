import Foundation

extension PlayerModel: PlaylistEventHandler {
	func selected(index: Int) {
		self.playingIndex = index
		self.reloadTrack()
	}
	
	func morePressed(index: Int) {
		
	}
}
