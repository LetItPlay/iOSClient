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
    var showChannels: Bool {get}
    var showEmptyMessage: Bool {get}
    var endReached: Bool {get}
	
	func make(action: TrackAction, index: Int)
	func stateChanged(_ state: ViewState)
    
    weak var delegate: FeedVMDelegate? {get set}
}

protocol FeedVMDelegate: class {
	func reload()
	func make(updates: [CollectionUpdate: [Int]])
    func updateTableState()
}

class FeedViewModel: FeedVMProtocol, FeedModelDelegate {
	
	var tracks: [TrackViewModel] = []
	weak var delegate: FeedVMDelegate?
    var model : FeedModelProtocol!
    var showChannels: Bool = false
    var showEmptyMessage: Bool = false
    var endReached: Bool = false
	
	init(model: FeedModelProtocol) {
		self.model = model
        self.model.delegate = self
	}
	
	func make(action: TrackAction, index: Int) {
		
	}
	
	func stateChanged(_ state: ViewState) {
		
	}
	
	func reload(tracks: [TrackViewModel]) {
		self.tracks = tracks
		self.delegate?.reload()
	}
    
    func show(tracks: [TrackViewModel], isContinue: Bool) {
        if isContinue {
            let indexes = self.tracks.count..<(self.tracks.count + tracks.count)
            self.tracks += tracks
            self.delegate?.make(updates: [CollectionUpdate.insert: Array(indexes)])
        } else {
            self.tracks = tracks
            self.delegate?.reload()
        }
    }
	
	func update(index: Int, track: TrackViewModel) {
		if index < self.tracks.count {
			self.tracks[index] = track
			self.delegate?.make(updates: [.update : [index]])
		}
	}
    
    func noDataLeft() {
        self.endReached = true
    }
}
