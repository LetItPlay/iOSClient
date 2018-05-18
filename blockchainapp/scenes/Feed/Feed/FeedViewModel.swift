import Foundation

enum CollectionUpdate {
	case insert, update, delete
}

protocol FeedVMProtocol: TrackHandlingViewModelProtocol {
}

protocol FeedVMDelegate: class {
}

class FeedViewModel: TrackHandlingViewModel, FeedVMProtocol, FeedModelDelegate {
	
    var isFeed: Bool = true
	weak var feedDelegate: FeedVMDelegate?
    
    func update(isFeed: Bool) {
        self.isFeed = isFeed
    }
    
    override func empty(show: Bool) {
        self.showEmpty = isFeed ? show : false
        self.delegate?.reloadAppearence()
    }
	
    func showAllChannels() {
        MainRouter.shared.show(screen: "allChannels", params: [:], present: false)
    }
    
    func showSearch() {
        MainRouter.shared.show(screen: "search", params: [:], present: false)
    }
}
