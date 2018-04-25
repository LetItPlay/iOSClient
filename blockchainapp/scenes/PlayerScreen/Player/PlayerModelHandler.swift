import Foundation

extension PlayerModel: PlayerEventHandler {
	func execute(event: PlayerEvent) {
		switch event {
		case .plause:
			switch self.player.status {
			case .playing:
				self.player.make(command: .pause)
			case .paused:
				self.player.make(command: .play)
			default:
				self.player.make(command: .pause)
			}
		case .change(let direction):
			self.playingIndex = direction == .backward
				? max(self.playingIndex - 1, 0)
				: min(self.playingIndex + 1, self.tracks.count - 1)
			self.reloadTrack()
		case .seekDir(let direction):
			let newTime = self.currentTime.current + (direction == .forward ? 10.0 : -10.0)
			if newTime > 0 && newTime < self.currentTime.length {
				self.player.make(command: .seek(progress: newTime / self.currentTime.length))
			}
		case .seek(let progress):
			self.player.make(command: .seek(progress: progress))
		}
	}
	
    func channelPressed() {
        //TODO: Close player and push channel screen
    }
	
	func setSpeed(index: Int) {
		// TODO: make speed change
        self.player.set(rate: self.speedConstants[index].value)
	}
	
	func send(event: LifeCycleEvent) {
		switch event {
		default:
			break
		}
	}
	
	func morePressed() {
        //TODO: Show more dialog
	}
}
