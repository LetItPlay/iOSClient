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

class PlayerViewModel: PlayerModelDelegate {
    var track: TrackViewModel = TrackViewModel()
    var channel: SearchChannelViewModel?
    var currentTime: Float = 0.0
    var currentTimeState: (past: String, future: String) = (past: "", future: "")
    var status: [PlayerControlsStatus : Bool] = [.isPlaying : false, .canForward: false, .canBackward: false]

    func update(status: [PlayerControlsStatus: Bool]) {
        self.status = status
    }

    func update(progress: Float, currentTime: String, leftTime: String) {
        self.currentTime = progress
        self.currentTimeState.past = currentTime
        self.currentTimeState.future = leftTime
    }
	
	func update(track: TrackViewModel) {
		self.track = track
	}
}
