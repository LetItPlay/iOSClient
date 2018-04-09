import Foundation

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
    var player: AudioPlayer!
    // TODO: Specify speed constants
    let speedConstants: [String: Float] = ["x0.5": 0.5, "x1.0": 1.0]

    init(player: AudioPlayer) {
        self.player = player
    }

    func loadPlaylist(tracks: [Track],
                      name: String = "Current Playlist".localized, playingId: Int?) {
        self.tracks = tracks
        self.playlistName = name
        if let id = playingId, let index = tracks.index(where: {$0.id == id}) {
            self.playingIndex = index
            self.player.load(item: self.tracks[index].audioTrack())
        }
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