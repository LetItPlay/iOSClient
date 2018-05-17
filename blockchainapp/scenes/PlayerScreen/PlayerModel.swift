import Foundation
import MediaPlayer

protocol PlayerEventHandler: ModelProtocol {
    func execute(event: PlayerEvent)
    func setSpeed(index: Int)
}

protocol PlaylistEventHandler: ModelProtocol {
    func track(selectedIndex index: Int)
    func showOthers(index: Int)
}

class PlayerModel {

    weak var playerDelegate: (PlayerModelDelegate & MainPlayerModelDelegate)?
    weak var playlistDelegate: PlaylistModelDelegate?
    weak var trackInfoDelegate: TrackInfoDelegate?

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

    let speedConstants: [(text: String, value: Float)] = [(text: "x 0.25", value: 0.25), (text: "x 0.5", value: 0.5), (text: "x 0.75", value: 0.75), (text: LocalizedStrings.SystemMessage.defaultMessage, value: 1), (text: "x 1.25", value: 1.25), (text: "x 1.5", value: 1.5), (text: "x 2", value: 2)]

    init(player: AudioPlayer) {
        self.player = player
		self.player.delegate = self

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
            self.execute(event: .seekDirection(.forward))
            return .success
        }
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }

    func updateStatus() {
        self.playerDelegate?.update(status:
        [.isPlaying: self.player.status == .playing,
         .canForward: self.playingIndex != self.tracks.count - 1,
         .canBackward: self.playingIndex != 0])
    }

    func reloadTrack() {
        _ = self.player.status
        if let item = self.currentTrack {
            self.trackInfoDelegate?.update(track: item)
			self.playerDelegate?.update(track: TrackViewModel(track: item))
            self.playerDelegate?.update(speeds: self.speedConstants.map({$0.text}))
            self.player.load(item: item.audioTrack())
//            self.player.make(command: prev == .playing ? .play : .pause)
        }
    }
    
    func track(selectedIndex index: Int) {
        var dict = [Int: Bool]()
        if self.playingIndex == index {
            self.player.make(command: self.player.status == .playing ? .pause : .play)
            dict[self.tracks[index].id] = self.player.status == .playing
        } else {
            dict[self.currentTrack?.id ?? -1] = false
            dict[self.tracks[index].id] = true
            self.playingIndex = index
            self.reloadTrack()
            self.player.make(command: .play)
        }
        NotificationCenter.default.post(name: AudioStateNotification.changed.notification(), object: nil, userInfo: dict)
    }
    
    func updatePlaylist() {
        self.playlistDelegate?.reload(
            tracks: self.tracks.map({TrackViewModel.init(track: $0, isPlaying: self.playingNow == $0.id)}),
            count: Int64(self.tracks.count).formatAmount(),
            length: Int64(self.tracks.map({$0.length}).reduce(0, +)).formatTime())
        self.playlistDelegate?.re(name: self.playlistName)
    }
}

extension PlayerModel: AudioPlayerDelegate {
    func update(status: PlayerStatus, id: Int) {
        if let index = self.tracks.index(where: {$0.id == id}) {
            self.playlistDelegate?.update(dict: [index: TrackViewModel.init(track: self.tracks[index], isPlaying: status == .playing)])
            let name = status == .playing ? AudioStateNotification.playing.notification() : AudioStateNotification.paused.notification()
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["id": id])
        }
        self.updateStatus()
    }
    
    func update(items: [Int: Bool]) {
        var dict = [Int: TrackViewModel]()
        for tuple in items {
            if let index = self.tracks.index(where: {tuple.key == $0.id}) {
                let vm = TrackViewModel.init(track: self.tracks[index], isPlaying: tuple.value)
                dict[index] = vm
            }
        }
        if dict.count > 0 {
            self.playlistDelegate?.update(dict: dict)
        }
        NotificationCenter.default.post(name: AudioStateNotification.changed.notification(), object: nil, userInfo: items)
        self.updateStatus()
    }
    
    func update(time: AudioTime) {
        self.currentTime = time
        self.playerDelegate?.update(progress: Float(time.current/time.length),
                currentTime: Int64(round(time.current)).formatTime(),
                leftTime: "-" + Int64(max(0, round(time.length - time.current))).formatTime())
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
