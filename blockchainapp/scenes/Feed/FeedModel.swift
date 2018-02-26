import Foundation
import RxSwift
import Action

protocol FeedModelProtocol: class, ModelProtocol {
    weak var delegate: FeedModelDelegate? {get set}
	var playingIndex: Variable<Int?> {get}
}

protocol FeedEventHandler: class {
    func trackSelected(index: Int)
    func trackLiked(index: Int)
    func reload()
    func trackShowed(index: Int)
}

protocol FeedModelDelegate: class {
	func show(tracks: [TrackViewModel], isContinue: Bool)
	func trackUpdate(index: Int, vm: TrackViewModel)
    func noDataLeft()
    func showChannels(_ show: Bool)
}

class FeedModel: FeedModelProtocol,
FeedEventHandler {
	
	private let isFeed: Bool
	private var currentOffest: Int = 0
    private let amount: Int = 100
    private var threshold: Bool = false
	
	weak var delegate: FeedModelDelegate?
	
	private var tracks: [Track1] = []
	private var channels: Set<Channel1> = Set<Channel1>()
	var playingIndex: Variable<Int?> = Variable<Int?>(nil)
	
	private var dataAction: Action<Int, ([Track1],[Channel1])>?
	private let disposeBag = DisposeBag()
	
	init(isFeed: Bool) {
		self.isFeed = isFeed
        
		dataAction = Action<Int, ([Track1],[Channel1])>.init(workFactory: { (offset) -> Observable<([Track1],[Channel1])> in
			return RequestManager.shared.tracks(req: self.isFeed ? TracksRequest.feed(channels: SubscribeManager.shared.channels, offset: offset, count: self.amount) : TracksRequest.trends(7))
		})
		
		dataAction?.elements.do(onNext: { (tuple) in
			if self.currentOffest == 0 {
				self.tracks = tuple.0
			} else {
				self.tracks += tuple.0
			}
			tuple.1.forEach({ (channel) in
				self.channels.insert(channel)
			})
		}).map({ (tuple) -> [TrackViewModel] in
			let playingId = AudioController.main.currentTrack?.id
			return tuple.0.map({ (track) -> TrackViewModel in
				var vm = TrackViewModel(track: track,
										isPlaying: track.id == playingId)
				if let channel = tuple.1.filter({$0.id == track.channelId}).first {
					vm.authorImage = channel.image
					vm.author = channel.name
				}
				return vm
			})
		}).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
			self.delegate?.show(tracks: vms, isContinue: self.currentOffest != 0)
			self.currentOffest = self.tracks.count
		}, onCompleted: {
            self.threshold = false
			print("Track loaded")
		}).disposed(by: self.disposeBag)
        
        
		
        InAppUpdateManager.shared.subscribe(self)
	}
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.dataAction?.execute(0)
        case .appear:
            self.delegate?.showChannels(!isFeed)
        case .disappear:
            break
        case .deinitialize:
            break
        }
    }
    
    func trackSelected(index: Int) {
		let tracks = self.tracks.map { (track) -> AudioTrack in
			return track.audioTrack(author: channels.first(where: {$0.id == track.channelId})?.name ?? "")
		}
        AudioController.main.loadPlaylist(playlist: ("Feed".localized, tracks), playId: self.tracks[index].id)
    }
    
    func trackLiked(index: Int) {
        let track = self.tracks[index]
        let action: TrackAction = track.isLiked ? TrackAction.unlike : TrackAction.like
        ServerUpdateManager.shared.make(track: track, action: action)
    }
    
    func reload() {
        self.currentOffest = 0
        self.dataAction?.execute(0)
    }
    
    func trackShowed(index: Int) {
        if index > self.tracks.count - self.amount/10 && !self.threshold {
            self.threshold = true
            self.dataAction?.execute(self.tracks.count)
        }
    }
}

extension FeedModel: SettingsUpdateProtocol, PlayingStateUpdateProtocol, SubscriptionUpdateProtocol, TrackUpdateProtocol {
    func channelSubscriptionUpdated() {
        self.reload()
    }
    
    func settingsUpdated() {
        self.reload()
    }
    
    func trackPlayingUpdate(id: Int, isPlaying: Bool) {
        if isPlaying {
            if let index = self.tracks.index(where: {$0.id == id}) {
                self.playingIndex.value = index
            }
        } else {
            self.playingIndex.value = nil
        }
    }
    
    func trackUpdated(track: Track1) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.delegate?.trackUpdate(index: index, vm: vm)
        }
    }
}

