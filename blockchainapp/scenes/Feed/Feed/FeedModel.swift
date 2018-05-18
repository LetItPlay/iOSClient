import Foundation
import Action

protocol FeedModelProtocol: ModelProtocol {
    var feedDelegate: FeedModelDelegate? {get set}
}

protocol FeedEventHandler: class {
	func showAllChannels()
	func showSearch()
}

protocol FeedModelDelegate: class {
	func showAllChannels()
	func showSearch()
    func update(isFeed: Bool)
}

class FeedModel: TrackHandlingModel, FeedModelProtocol, FeedEventHandler {
    var isFeed: Bool
	
	weak var feedDelegate: FeedModelDelegate?
			
    init(isFeed: Bool, name: String, dataAction: Action<Int, [Track]>) {
        self.isFeed = isFeed
        super.init(name: name, dataAction: dataAction)
    }
    
    override func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.feedDelegate?.update(isFeed: self.isFeed)
            if self.isFeed
            {
                UserSettings.session = UUID.init().uuidString
            }
        default:
            break
        }
        
        super.send(event: event)
    }
	
	func showSearch() {
		self.feedDelegate?.showSearch()
	}
    func showAllChannels() {
        self.feedDelegate?.showAllChannels()
    }
}

extension FeedModel: SubscriptionUpdateProtocol {
    
    func channelSubscriptionUpdated() {
        self.reload()
    }
}

