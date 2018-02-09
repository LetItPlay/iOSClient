import Foundation

enum CollectionUpdate {
	case insert, update, delete
}

enum TrackAction {
	case selected, liked, reported
}

enum ViewState {
	case initialize, show, dismiss, destroyed
}

protocol FeedVMProtocol {
	var tracks: [TrackViewModel] {get}
	var currentPlayingIndex: Int? {get}
	
	func make(action: TrackAction, index: Int)
	func stateChanged(_ state: ViewState)
}

protocol FeedVMDelegate: class {
	func reload()
	func make(updates: [CollectionUpdate: [Int]])
}

class FeedViewModel: FeedVMProtocol, FeedModelDelegate {
	
	var tracks: [TrackViewModel] = []
	var currentPlayingIndex: Int? = nil
	weak var delegate: FeedVMDelegate?
	private var model : FeedModelProtocol!
	
	init(model: FeedModelProtocol) {
		self.model = model
	}
	
	func make(action: TrackAction, index: Int) {
		
	}
	
	func stateChanged(_ state: ViewState) {
		
	}
	
	func reload(tracks: [TrackViewModel]) {
		self.tracks = tracks
		self.delegate?.reload()
    }
    
    func update(index: Int, track: TrackViewModel) {
        self.delegate?.make(updates: [.update: [index]])
    }
}
