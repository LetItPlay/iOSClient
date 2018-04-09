import Foundation

enum SeekDirection {
    case forward, backward
}

enum PlayerEvent {
    case plause, next, prev, seek(dir: SeekDirection), seek(progress: Double)
}

enum PlayerTrackEvent {
    case likePressed, channelPressed
}

class PlayerEmitter: Emitter {

    weak var handler: PlayerEventHandler?

    convenience init(handler: (PlayerEventHandler & ModelProtocol)) {
        self.init(handler: handler)
        self.handler = handler
    }

    func send(event: PlayerEvent) {
        self.handler.execute(event: event)
    }

    func setSpeed(index: Int) {

    }

    func send(event: PlayerTrackEvent) {
        self.handler.execute(event: event)
    }

    func morePressed(index: Int) {
        self.handler.morePressed(index: index)
    }
}

class PlaylistEmitter: Emitter {

}