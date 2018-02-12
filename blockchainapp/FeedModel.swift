import Foundation
import RxSwift
import Action

protocol FeedModelProtocol {
	
}

protocol FeedModelDelegate: class {
	func show(tracks: [TrackViewModel], isContinue: Bool)
	func update(index: Int, track: TrackViewModel)
}

class FeedModel {
	
	private let isFeed: Bool
	
	private var currentOffest: Int = 0
	
	private var sort: (Track, Track) -> Bool? = {_,_ in return nil}
	private let date = Date().addingTimeInterval(-60*60*24*7)
	private var filter: (Track) -> Bool = {_ in return true}
	
	weak var delegate: FeedModelDelegate?
	
	private var tracks: [Track1] = []
	private var playingIndex: Int? = nil
	
	private var dataAction: Action<Int, ([Track1],[Station1])>?
	private let disposeBag = DisposeBag()
	
	init(isFeed: Bool) {
		self.isFeed = isFeed
		
		dataAction = Action<Int, ([Track1],[Station1])>.init(workFactory: { (offset) -> Observable<([Track1],[Station1])> in
			return RequestManager.shared.tracks(req: self.isFeed ? TracksRequest.trends(7) : TracksRequest.feed(stations: SubscribeManager.shared.stations, offset: offset, count: 100))
		})
		
		dataAction?.elements.do(onNext: { (tuple) in
			if self.currentOffest == 0 {
				self.tracks = tuple.0
			} else {
				self.tracks += tuple.0
			}
		}).map({ (tuple) -> [TrackViewModel] in
			let playingId = AudioController.main.currentTrack?.id
			return tuple.0.map({ (track) -> TrackViewModel in
				var vm = TrackViewModel(track: track,
										isPlaying: track.idString() == playingId ,
										isLiked: LikeManager.shared.hasObject(id: track.id))
				if let station = tuple.1.filter({$0.id == track.id}).first {
					vm.authorImage = station.image
					vm.author = station.name
				}
				return vm
			})
		}).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
			self.delegate?.show(tracks: vms, isContinue: self.currentOffest == 0)
			self.currentOffest = self.tracks.count
		}, onCompleted: {
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

	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.idString() == id}) {
			if let curr = self.playingIndex {
				let newVM = TrackViewModel(track: tracks[curr], isPlaying: false)
				self.delegate?.update(index: curr, track: newVM)
			}
			let newVM = TrackViewModel(track: tracks[index], isPlaying: false)
			self.delegate?.update(index: index, track: newVM)
		}
	}

	@objc func trackPaused(notification: Notification) {
//		if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
//		}
	}

	@objc func subscriptionChanged(notification: Notification) {
		
	}
	
	func reload() {
		self.dataAction?.execute(0)
	}
	
	func dataRequested() {
		self.dataAction?.execute(self.tracks.count)
	}
}

