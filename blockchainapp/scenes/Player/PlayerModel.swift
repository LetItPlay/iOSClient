import Foundation
import MediaPlayer

protocol PlaylistModelDelegate: class {

}

protocol PlayerModelDelegate: class {

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
    private var currentTrack: Track = {
        get {
            if self.playingIndex < 0 { return nil }
            return self.tracks[self.playingIndex]
        }
    }
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
            self.execute(event: .next)
            return .success
        }

        mpcenter.skipBackwardCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.execute(event: .seek(dir: .forward))
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
}

extension PlayerModel: PlayerTrackEvent {
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
        case .next, .prev:
            var prev = self.player.status
            self.playingIndex = event == .prev
                    ? max(self.playingIndex - 1, 0)
                    : min(self.playingIndex + 1, self.tracks.count - 1)
            if let item = self.currentTrack {
                self.player.load(item: item)
                self.player.make(command: prev == .playing ? .play : .pause)
            }
        case .seek(let direction: SeekDirection), .seek(let progress: Float):

        default:
            break
        }
    }

    func execute(event: PlayerTrackEvent) {

    }

    func setSpeed(index: Int) {
        // TODO: make speed change
    }

    func send(event: LifeCycleEvent) {

    }
}

extension PlayerModel: AudioPlayerDelegate {
    func update(status: PlayerStatus, id: Int) {

    }

    func update(time: AudioTime) {

    }

    func itemFinishedPlaying(id: Int) {
        if self.tracks.last?.id == id {

        } else {

        }
    }
}