import Foundation

enum Direction {
    case forward, backward
}

enum PlayerEvent {
    case plause, change(dir: Direction), seekDir(dir: Direction), seek(progress: Double)
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

    func channelPressed() {
        self.handler?.channelPressed()
    }

    func morePressed() {
        self.handler?.morePressed()
    }
}
