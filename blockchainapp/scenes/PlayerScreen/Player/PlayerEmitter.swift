import Foundation

enum Direction {
    case forward, backward
}

enum PlayerEvent {
    case plause, change(dir: Direction), seekDir(dir: Direction), seek(progress: Double)
}

enum PlayerTrackEvent {
    case likePressed, channelPressed
}

class PlayerEmitter: Emitter {

    weak var handler: PlayerEventHandler?

    convenience init(model: (PlayerEventHandler & ModelProtocol)) {
        self.init(handler: model)
        self.handler = model
    }

    func send(event: PlayerEvent) {
        self.handler?.execute(event: event)
    }

    func setSpeed(index: Int) {

    }

    func send(event: PlayerTrackEvent) {
        self.handler?.execute(event: event)
    }

    func morePressed() {
        self.handler?.morePressed()
    }
}