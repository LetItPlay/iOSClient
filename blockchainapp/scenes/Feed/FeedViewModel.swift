import Foundation
import RxSwift

enum CollectionUpdate {
	case insert, update, delete
}

protocol FeedVMProtocol {
	var tracks: [TrackViewModel] {get}
    var showChannels: Bool {get}
    var showEmptyMessage: Bool {get}
    var endReached: Bool {get}
    
    weak var delegate: FeedVMDelegate? {get set}
}

protocol FeedVMDelegate: class {
	func reload()
	func make(updates: [CollectionUpdate: [Int]])
    func updateTableState()
    func updateEmptyMessage()
}

class FeedViewModel: FeedVMProtocol, FeedModelDelegate {
	
	var tracks: [TrackViewModel] = []
	weak var delegate: FeedVMDelegate?
    var model : FeedModelProtocol!
    var showChannels: Bool = false
    var showEmptyMessage: Bool = false
    var endReached: Bool = false
	
	let disposeBag = DisposeBag()
	
	init(model: FeedModelProtocol) {
		self.model = model
        self.model.delegate = self
		
		self.model.playingIndex.asObservable().scan(nil) { (res, index) -> (Int?, Int?) in
			return (res?.1, index)
			}.subscribe(onNext: { (tuple) in
				if let tuple = tuple {
					var indexes = [Int]()
					if let old = tuple.0 {
						var vm = self.tracks[old]
						vm.isPlaying = false
						self.tracks[old] = vm
						indexes.append(old)
					}
					if let new = tuple.1 {
						var vm = self.tracks[new]
						vm.isPlaying = true
						self.tracks[new] = vm
						indexes.append(new)
					}
					self.delegate?.make(updates: [.update: indexes])
				}
			}).disposed(by: disposeBag)
	}
	
	func reload(tracks: [TrackViewModel]) {
		self.tracks = tracks
		self.delegate?.reload()
	}

    func show(tracks: [TrackViewModel], isContinue: Bool) {
        if isContinue {
            let indexes = self.tracks.count..<(self.tracks.count + tracks.count)
            self.tracks += tracks
            self.delegate?.make(updates: [.insert: Array(indexes)])
        } else {
            self.tracks = tracks
            self.delegate?.reload()
        }
    }
	
	func trackUpdate(index: Int, vm: TrackViewModel) {
		var old = self.tracks[index]
		old.update(vm: vm)
		self.tracks[index] = old
		self.delegate?.make(updates: [.update: [index]])
	}
    
    func noDataLeft() {
        self.endReached = true
    }
    
    func showChannels(_ show: Bool) {
        self.showChannels = show
    }
    
    func showEmptyMessage(_ show: Bool) {
        self.showEmptyMessage = show
        self.delegate?.updateEmptyMessage()
    }
    
    func showAllChannels() {
        MainRouter.shared.show(screen: "allChannels", params: [:], present: false)
    }
}
