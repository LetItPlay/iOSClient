import Foundation
import MediaPlayer

protocol PlaylistModelDelegate: class {

}

protocol PlayerModelDelegate: class {
    func update(status: [PlayerControlsStatus : Bool])
    func update(progress: Float, currentTime: String, leftTime: String)
}

protocol PlayerEventHandler: ModelProtocol {
    func execute(event: PlayerEvent)
    func execute(event: PlayerTrackEvent)
    func setSpeed(index: Int)
    func morePressed(index: Int)
}

class PlayerModel {

    weak var playerDelegate: PlayerModelDelegate?
    weak var playlistDelegate: PlaylistModelDelegate?

    var playlistName: String = ""
    var tracks: [Track] = []
    var playingIndex: Int = -1
    private var currentTrack: Track? {
        get {
            if self.playingIndex < 0 { return nil }
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

    func loadPlaylist(tracks: [Track],
                      name: String = "Current Playlist".localized, playingId: Int?) {
        self.tracks = tracks
        self.playlistName = name
        if let id = playingId, let index = tracks.index(where: {$0.id == id}) {
            self.playingIndex = index
            self.player.load(item: self.tracks[index].audioTrack())
        }
        // TODO: Update playlist
    }

    func add(track: Track, onTop: Bool) {
        if !self.tracks.contains(where: {$0.id == track.id}) {
            if onTop {
                self.tracks.insert(track, at: self.playingIndex + 1)
            } else {
                self.tracks.append(track)
            }
            // TODO: Update playlist
        }
    }

    func updateStatus() {
        self.playerDelegate.update(status:
        [.isPlaying: self.player.status == .playing,
         .canForward: self.playingIndex != self.tracks.count - 1,
         .canBackward: self.playingIndex != 0])
    }
}

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
            let prev = self.player.status
            self.playingIndex = direction == .backward
                    ? max(self.playingIndex - 1, 0)
                    : min(self.playingIndex + 1, self.tracks.count - 1)
            if let item = self.currentTrack?.audioTrack() {
                self.player.load(item: item)
                self.player.make(command: prev == .playing ? .play : .pause)
            }

        case .seekDir(let direction):
            let newTime = self.currentTime.current + (direction == .forward ? 10.0 : -10.0)
            if newTime > 0 && newTime < self.currentTime.length {
                self.player.make(command: .seek(progress: newTime / self.currentTime.length))
            }
        case .seek(let progress):
            self.player.make(command: .seek(progress: progress))
        }
    }

    func execute(event: PlayerTrackEvent) {

    }

    func setSpeed(index: Int) {
        // TODO: make speed change
    }

    func send(event: LifeCycleEvent) {
        switch event {
        default:
            break
        }
    }

    func morePressed(index: Int) {

    }
}

extension PlayerModel: AudioPlayerDelegate {
    func update(status: PlayerStatus, id: Int) {
        if let item = self.currentTrack.id, item.id == id {

        }
    }

    func update(time: AudioTime) {
        self.currentTime = time
        self.playerDelegate.update(progress: time.current/time.length,
                currentTime: Int64(round(time.current)).formatTime(),
                leftTime: "-" + Int64(min(0, round(time.length - time.current))).formatTime())
    }

    func itemFinishedPlaying(id: Int) {
        if self.tracks.last?.id == id {
            self.updateStatus()
        }
    }
}