import Foundation

enum FeedEvent {
    case trackSelected(index: Int)
    case trackLiked(index: Int)
    case refresh
    case showing(index: Int)
    case showAllChannels()
    case addTrack(atIndex: Int, toBeginig: Bool)
    case showSearch
    case showChannel(atIndex: Int)
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
        switch event {
        case .refresh:
            self.model?.reload()
        case .showing(let index):
            self.model?.trackShowed(index: index)
        case .trackLiked(let index):
            self.model?.trackLiked(index: index)
        case .trackSelected(let index):
            self.model?.trackSelected(index: index)
        case .showAllChannels():
            self.model?.showAllChannels()
        case .addTrack(let index, let toBeginig):
            self.model?.addTrack(index: index, toBegining: toBeginig)
        case .showSearch:
            self.model?.showSearch()
        case .showChannel(let index):
            self.model?.showChannel(index: index)
        }
    }
}
