import Foundation
import MediaPlayer

protocol PlaylistModelDelegate: class {
	func reload(tracks: [TrackViewModel], count: String, length: String)
	func update(track: TrackViewModel, asIndex index: Int)
	func re(name: String)
}

protocol MainPlayerModelDelegate: class {
	func showSpeedSettings()
	func showMoreDialog()
	func player(show: Bool)
}

protocol PlayerModelDelegate: class {
    func update(status: [PlayerControlsStatus : Bool])
    func update(progress: Float, currentTime: String, leftTime: String)
    func update(track: TrackViewModel)
}

protocol PlayerEventHandler: ModelProtocol {
    func execute(event: PlayerEvent)
    func execute(event: PlayerTrackEvent)
    func setSpeed(index: Int)
    func morePressed()
}

protocol PlaylistEventHandler: ModelProtocol {
    func selected(index: Int)
    func morePressed(index: Int)
}

class PlayerModel {

    weak var playerDelegate: (PlayerModelDelegate & MainPlayerModelDelegate)?
    weak var playlistDelegate: PlaylistModelDelegate?
	weak var mainDelegate: MainPlayerModelDelegate?

    var playlistName: String = ""
    var tracks: [Track] = []
    var playingIndex: Int = -1
	internal var currentTrack: Track? {
        get {
            if self.playingIndex < 0 || self.playingIndex >= self.tracks.count { return nil }
            return self.tracks[self.playingIndex]
        }
    }
    var currentTime: AudioTime = AudioTime(current: 0, length: 0)
    var player: AudioPlayer!
    // TODO: Specify speed constants
    let speedConstants: [String: Float] = ["x0.5": 0.5, "x1.0": 1.0]

    init(player: AudioPlayer) {
        self.player = player

        let mpcenter = MPRemoteCommandCenter.shared()
        mpcenter.playCommand.isEnabled = true
        mpcenter.pauseCommand.isEnabled = true
        mpcenter.nextTrackCommand.isEnabled = true
        mpcenter.skipBackwardCommand.isEnabled = true
        mpcenter.skipBackwardCommand.preferredIntervals = [10]
        mpcenter.previousTrackCommand.isEnabled = false

        mpcenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.execute(event: .plause)
            return .success
        }

        mpcenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.execute(event: .plause)
            return .success
        }

        mpcenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.execute(event: .change(dir: .forward))
            return .success
        }

        mpcenter.skipBackwardCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.execute(event: .seekDir(dir: .forward))
            return .success
        }
    }

    func updateStatus() {
        self.playerDelegate?.update(status:
        [.isPlaying: self.player.status == .playing,
         .canForward: self.playingIndex != self.tracks.count - 1,
         .canBackward: self.playingIndex != 0])
    }

    func reloadTrack() {
        let prev = self.player.status
        if let item = self.currentTrack {
			self.playerDelegate?.update(track: TrackViewModel(track: item))
            self.player.load(item: item.audioTrack())
            self.player.make(command: prev == .playing ? .play : .pause)
        }
    }
}

extension PlayerModel: AudioPlayerDelegate {
    func update(status: PlayerStatus, id: Int) {
        if let item = self.currentTrack?.id, item == id {
        }
        self.updateStatus()
    }

    func update(time: AudioTime) {
        self.currentTime = time
        self.playerDelegate?.update(progress: Float(time.current/time.length),
                currentTime: Int64(round(time.current)).formatTime(),
                leftTime: "-" + Int64(min(0, round(time.length - time.current))).formatTime())
    }

    func itemFinishedPlaying(id: Int) {
        if self.tracks.last?.id == id {
            self.player.make(command: .pause)
        } else {
            self.execute(event: .change(dir: .forward))
        }
        self.updateStatus()
    }
}
