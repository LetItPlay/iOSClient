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
}

class FeedModel: FeedModelProtocol, FeedEventHandler, SettingsUpdateProtocol {
	
	private let isFeed: Bool
	private var currentOffest: Int = 0
    private let amount: Int = 100
    private var threshold: Bool = false
	
	weak var delegate: FeedModelDelegate?
	
	private var tracks: [Track1] = []
	private var channels: Set<Station1> = Set<Station1>()
	var playingIndex: Variable<Int?> = Variable<Int?>(nil)
	
	private var dataAction: Action<Int, ([Track1],[Station1])>?
	private let disposeBag = DisposeBag()
	
	init(isFeed: Bool) {
		self.isFeed = isFeed
		
        
		dataAction = Action<Int, ([Track1],[Station1])>.init(workFactory: { (offset) -> Observable<([Track1],[Station1])> in
			return RequestManager.shared.tracks(req: self.isFeed ? TracksRequest.feed(stations: SubscribeManager.shared.stations, offset: offset, count: self.amount) : TracksRequest.trends(7))
		})
		
		dataAction?.elements.do(onNext: { (tuple) in
			if self.currentOffest == 0 {
				self.tracks = tuple.0
			} else {
				self.tracks += tuple.0
			}
			tuple.1.forEach({ (station) in
				self.channels.insert(station)
			})
		}).map({ (tuple) -> [TrackViewModel] in
			let playingId = AudioController.main.currentTrack?.id
			return tuple.0.map({ (track) -> TrackViewModel in
				var vm = TrackViewModel(track: track,
										isPlaying: track.id == playingId)
				if let station = tuple.1.filter({$0.id == track.stationId}).first {
					vm.authorImage = station.image
					vm.author = station.name
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
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(subscriptionChanged(notification:)),
											   name: SubscribeManager.NotificationName.added.notification,
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(subscriptionChanged(notification:)),
											   name: SubscribeManager.NotificationName.deleted.notification,
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPlayed(notification:)),
											   name: AudioController.AudioStateNotification.playing.notification(),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPaused(notification:)),
											   name: AudioController.AudioStateNotification.paused.notification(),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(settingsChanged(notification:)),
											   name: SettingsNotfification.changed.notification(),
											   object: nil)
        InAppUpdateManager.shared.subscribe(self)
	}

    func settingsUpdated() {
        self.reload()
    }

    deinit {
		NotificationCenter.default.removeObserver(self)
	}

	@objc func settingsChanged(notification: Notification) {
		self.reload()
	}
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.dataAction?.execute(0)
        case .appear:
            break
        case .disappear:
            break
        case .deinitialize:
            break
        }
    }
    
    func trackSelected(index: Int) {
		let tracks = self.tracks.map { (track) -> AudioTrack in
			return track.audioTrack(author: channels.first(where: {$0.id == track.stationId})?.name ?? "")
		}
        AudioController.main.loadPlaylist(playlist: ("Feed".localized, tracks), playId: self.tracks[index].id)
    }
    
    func trackLiked(index: Int) {
        let track = self.tracks[index]
		track.likeCount += track.isLiked ? -1 : 1
		LikeManager.shared.addOrDelete(id: track.id)
		track.isLiked = LikeManager.shared.hasObject(id: track.id)
		self.tracks[index] = track
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

	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.idString() == id}) {
			self.playingIndex.value = index
		}
	}

	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.idString() == id}) {
			self.playingIndex.value = nil
		}
	}

	@objc func subscriptionChanged(notification: Notification) {
		self.reload()
	}
}

