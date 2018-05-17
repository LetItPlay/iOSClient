import Foundation

enum FeedEvent {
    case showAllChannels()
    case showSearch
}

enum LifeCycleEvent {
    case initialize
    case appear
    case disappear
    case deinitialize
}

protocol ModelProtocol: class {
    func send(event: LifeCycleEvent)
}

class Emitter {
    weak var lifecycleHandler: ModelProtocol?
    
    func send(event: LifeCycleEvent) {
        self.lifecycleHandler?.send(event: event)
    }
    
    init(handler: ModelProtocol) {
        self.lifecycleHandler = handler
    }
}

protocol LifeCycleHandlerProtocol {
    func send(event: LifeCycleEvent)
}
protocol FeedEmitterProtocol: TrackHandlingEmitterProtocol {
    func send(event: FeedEvent)
}

class FeedEmitter: TrackHandlingEmitter, FeedEmitterProtocol {
    weak var feedModel: FeedEventHandler?
    
    func send(event: FeedEvent) {
        switch event {
        case .showAllChannels():
            self.feedModel?.showAllChannels()
        case .showSearch:
            self.feedModel?.showSearch()
        }
    }
}
