import Foundation

protocol PlayerViewDelegate: class {
    func updateButtons()
    func updateTrack()
    func updateTime()
}

protocol TrackInfoViewDelegate: class {
    func updateTrack()
    func updateChannel()
}

enum PlayerControlsStatus {
    case isPlaying, canForward, canBackward
}

class PlayerViewModel: PlayerModelDelegate, MainPlayerModelDelegate {
    var track: TrackViewModel = TrackViewModel()
    var channel: SearchChannelViewModel?
    var currentTime: Float = 0.0
    var currentTimeState: (past: String, future: String) = (past: "", future: "")
    var status: [PlayerControlsStatus : Bool] = [.isPlaying : false, .canForward: false, .canBackward: false]

	weak var infoDelegate: TrackInfoViewDelegate?
	weak var playerDelegate: PlayerViewDelegate?
	
    func update(status: [PlayerControlsStatus: Bool]) {
        self.status = status
		self.playerDelegate?.updateButtons()
    }

    func update(progress: Float, currentTime: String, leftTime: String) {
        self.currentTime = progress
        self.currentTimeState.past = currentTime
        self.currentTimeState.future = leftTime
		self.playerDelegate?.updateTime()
    }
	
	func update(track: TrackViewModel) {
		self.track = track
		self.playerDelegate?.updateTrack()
	}
	
	func showSpeedSettings() {
		
	}
	
	func showMoreDialog() {
		
	}
	
	func player(show: Bool) {
		MainRouter.shared.miniPlayer(show: true, animated: true)
	}
}
