import Foundation

enum Direction {
    case forward, backward
}

enum PlayerEvent {
    case plause, change(dir: Direction), seekDirection(Direction), seekProgress(Double), clearAll(direction: HideMiniPlayerDirection)
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
        self.handler?.setSpeed(index: index)
    }
}
