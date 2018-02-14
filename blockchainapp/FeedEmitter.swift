import Foundation

enum FeedEvent {
    case trackSelected(index: Int)
    case trackLiked(index: Int)
    case refresh
    case showing(index: Int)
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
    var lifecycleHandler: ModelProtocol?
    
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
protocol FeedEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: FeedEvent)
}

class FeedEmitter: Emitter, FeedEmitterProtocol {
    weak var model: FeedEventHandler?
    
    convenience init(model: (FeedEventHandler & ModelProtocol)) {
        self.init(handler: model)
        self.model = model
    }
    
    func send(event: FeedEvent) {
        
    }
}
