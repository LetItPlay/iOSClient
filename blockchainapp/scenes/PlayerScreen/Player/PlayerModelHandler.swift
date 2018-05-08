import Foundation

extension PlayerModel: PlayerEventHandler {
	func execute(event: PlayerEvent) {
		switch event {
		case .plause:
			switch self.player.status {
			case .playing:
                AnalyticsEngine.sendEvent(event: .pause)
				self.player.make(command: .pause)
			case .paused:
                AnalyticsEngine.sendEvent(event: .play)
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
        case .clearAll(let direction):
            self.clearAll(direction: direction)
		}
	}
	
	func setSpeed(index: Int) {
        self.player.set(rate: self.speedConstants[index].value)
        self.playerDelegate?.update(currentSpeedIndex: index)
	}
	
	func send(event: LifeCycleEvent) {
		switch event {
		default:
			break
		}
	}
}
