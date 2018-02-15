import Foundation
import RxSwift
import Action

protocol FeedModelProtocol: class, ModelProtocol {
    weak var delegate: FeedModelDelegate? {get set}
}

protocol FeedEventHandler: class {
    func trackSelected(index: Int)
    func trackLiked(index: Int)
    func reload()
    func trackShowed(index: Int)
}

protocol FeedModelDelegate: class {
	func show(tracks: [TrackViewModel], isContinue: Bool)
	func update(index: Int, fields: [TrackUpdateFields: Any])
    func noDataLeft()
}

class FeedModel: FeedModelProtocol, FeedEventHandler {
	
	private let isFeed: Bool
	private var currentOffest: Int = 0
    private let amount: Int = 100
    private var threshold: Bool = false
	
	weak var delegate: FeedModelDelegate?
	
	private var tracks: [Track1] = []
	private var channels: Set<Station1> = Set<Station1>()
	private var playingIndex: Int? = nil
	
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
										isPlaying: track.idString() == playingId ,
										isLiked: LikeManager.shared.hasObject(id: track.id))
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
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	@objc func settingsChanged(notification: Notification) {

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
        AudioController.main.loadPlaylist(playlist: ("Feed".localized, tracks), playId: self.tracks[index].idString())
    }
    
    func trackLiked(index: Int) {
        
    }
    
    func reload() {
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
			if let curr = self.playingIndex {
				self.delegate?.update(index: curr, fields: [TrackUpdateFields.isPlaying: false])
			}
			self.delegate?.update(index: index, fields: [TrackUpdateFields.isPlaying: true])
			self.playingIndex = index
		}
	}

	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.idString() == id}) {
			self.delegate?.update(index: self.playingIndex ?? index, fields: [TrackUpdateFields.isPlaying: false])
			self.playingIndex = nil
		}
	}

	@objc func subscriptionChanged(notification: Notification) {
		self.reload()
	}
}

