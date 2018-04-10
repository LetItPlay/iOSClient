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
	func showAllChannels()
	func addTrack(index: Int, toBegining: Bool)
	func showSearch()
    func showChannel(index: Int)
}

protocol FeedModelDelegate: class {
	func show(tracks: [TrackViewModel], isContinue: Bool)
	func trackUpdate(index: Int, vm: TrackViewModel)
	func noDataLeft()
	func showChannels(_ show: Bool)
	func showEmptyMessage(_ show: Bool)
	func showAllChannels()
	func showSearch()
    func showChannel(id: Int)
}


class FeedModel: FeedModelProtocol,
FeedEventHandler {
	
	private let isFeed: Bool
	private var currentOffest: Int = 0
    private let amount: Int = 100
    private var threshold: Bool = false
	
	weak var delegate: FeedModelDelegate?
	
	private var tracks: [Track] = []
	private var channels: Set<Channel> = Set<Channel>()
	var playingIndex: Variable<Int?> = Variable<Int?>(nil)
	
	private var dataAction: Action<Int, [Track]>?
	private let disposeBag = DisposeBag()
	
	init(isFeed: Bool) {
		self.isFeed = isFeed
        
		dataAction = Action<Int, [Track]>.init(workFactory: { (offset) -> Observable<[Track]> in
			return RequestManager.shared.tracks(req: self.isFeed ? TracksRequest.feed(channels: SubscribeManager.shared.channels, offset: offset, count: self.amount) : TracksRequest.trends(offset: offset, count: self.amount) )
		})
		
		dataAction?.elements.do(onNext: { (tracks) in
			if self.currentOffest == 0 {
				self.tracks = tracks
			} else {
				self.tracks += tracks
			}
		}).map({ (tracks) -> [TrackViewModel] in
			let playingId = AudioController.main.currentTrack?.id
			return tracks.map({ TrackViewModel(track: $0,
											   isPlaying: $0.id == playingId) })
		}).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
			self.delegate?.show(tracks: vms, isContinue: self.currentOffest != 0)
            self.delegate?.showEmptyMessage(self.tracks.count == 0)
			self.currentOffest = self.tracks.count
		}, onCompleted: {
            self.threshold = false
			print("Track loaded")
		}).disposed(by: self.disposeBag)
        
        
		
        let _ = InAppUpdateManager.shared.subscribe(self)
	}
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            if self.isFeed
            {
                UserSettings.session = UUID.init().uuidString
            }
                
            self.dataAction?.execute(0)
        case .appear:
            self.delegate?.showChannels(!isFeed)
            if !self.isFeed {
                self.delegate?.showEmptyMessage(false)
            }
        case .disappear:
            break
        case .deinitialize:
            break
        }
    }
    
    func trackSelected(index: Int) {
		let tracks = self.tracks.map { (track) -> AudioTrack in
            return track.audioTrack()
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
	
	func addTrack(index: Int, toBegining: Bool) {
		let track = self.tracks[index]
		UserPlaylistManager.shared.add(track: track, toBegining: toBegining)
	}
	
	func showSearch() {
		self.delegate?.showSearch()
	}
    
    func showChannel(index: Int) {
        self.delegate?.showChannel(id: self.tracks[index].channel.id)
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
    
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.tracks[index] = track
            self.delegate?.trackUpdate(index: index, vm: vm)
        }
    }
    
    func showAllChannels() {
        self.delegate?.showAllChannels()
    }
}

