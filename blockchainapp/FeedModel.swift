import Foundation
import RealmSwift
import RxSwift

protocol FeedModelProtocol {
	
}

protocol FeedModelDelegate: class {
	func reload(tracks: [TrackViewModel])
	func update(index: Int, track: TrackViewModel)
}

class FeedModel {
	
	private let isFeed: Bool
	private var token: NotificationToken?
	
	private var sort: (Track, Track) -> Bool? = {_,_ in return nil}
	private let date = Date().addingTimeInterval(-60*60*24*7)
	private var filter: (Track) -> Bool = {_ in return true}
	
	weak var delegate: FeedModelDelegate?
	
	private var tracks: [Track] = []
	private var playingIndex: Int? = nil
	
	private let disposeBag = DisposeBag()
	
	init(isFeed: Bool) {
		self.isFeed = isFeed
		
		if let realm = try? Realm() {
			if (self.isFeed) {
				sort = { first, second in
					if first.publishedAt != second.publishedAt {
						return first.publishedAt > second.publishedAt
					}
					return nil}
			} else {
				sort = {$0.listenCount != $1.listenCount ? $0.listenCount > $1.listenCount : nil}
			}
			filter = self.isFeed ?
			{SubscribeManager.shared.stations.contains($0.station) && $0.lang == UserSettings.language.rawValue} :
			{_ in return true}
			let results = isFeed ?
				realm.objects(Track.self).filter("publishedAt >= %@ AND lang contains %@", date, UserSettings.language.rawValue) :
				realm.objects(Track.self).filter("lang contains %@", UserSettings.language.rawValue)
			
			token = results.observe({ (changes: RealmCollectionChange) in
				switch changes {
				case .initial:
					// Results are now populated and can be accessed without blocking the UI
					self.tracks = Array(results).filter(self.filter).sorted(by: { (first, second) -> Bool in
						if let res = self.sort(first, second) {
							return res
						} else {
							return first.name < second.name
						}
					})
					self.delegate?.reload(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
					
				case .update(_, let deletions, let insertions, let modifications):
					// Query results have changed, so apply them to the UITableView
					self.tracks = Array(results).filter(self.filter).sorted(by: { (first, second) -> Bool in
						if let res = self.sort(first, second) {
							return res
						} else {
							return first.name < second.name
						}
					})
					self.delegate?.reload(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
					let update = modifications.map({ (index) -> (Int, Track)? in
						if let index = self.tracks.index(where: {$0.id == results[index].id}) {
							return (index, results[index])
						}
						return nil
					}).filter({$0 != nil}).map({$0!})
//					let delete = deletions.map({ (index) -> Int? in
//						return self?.tracks.index(where: {$0.id == results[index].id})
//					}).filter({$0 != nil}).map({$0!})
//					let insert = insertions.map({ (index) -> Int? in
//						return self?.tracks.index(where: {$0.id == results[index].id})
//					}).filter({$0 != nil}).map({$0!})
//					self?.view?.reload(update: update, delete: delete, insert: insert)
					update.forEach({ (ind) in
						self.delegate?.update(index: ind.0, track: TrackViewModel(track: ind.1))
					})
				case .error(let error):
					// An error occurred while opening the Realm file on the background worker thread
					fatalError("\(error)")
				}
			})
		}
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
		token?.invalidate()
	}

	@objc func settingsChanged(notification: Notification) {

	}

	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
			if let curr = self.playingIndex {
				let newVM = TrackViewModel(track: tracks[curr], isPlaying: false)
				self.delegate?.update(index: curr, track: newVM)
			}
			let newVM = TrackViewModel(track: tracks[index], isPlaying: false)
			self.delegate?.update(index: index, track: newVM)
//			var reload = [Int]()
//			if playingIndex != -1 {
//				reload.append(playingIndex)
//			}
//			reload.append(index)
//			self.playingIndex = index
//			self.view?.reload(update: reload, delete: [], insert: [])
		}
	}

	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
//			var reload = [Int]()
//			if playingIndex != -1 {
//				reload.append(playingIndex)
//			}
//			self.playingIndex = -1
//			self.view?.reload(update: reload, delete: [], insert: [])
		}
	}
//
	@objc func subscriptionChanged(notification: Notification) {
		
	}

//	func getData(onComplete: @escaping TrackResult) {
//		DownloadManager.shared.channelsSignal().observeOn(MainScheduler.init()).subscribe( onCompleted: {
//			DownloadManager.shared.requestTracks(all: !self.isFeed, success: { (feed) in
//
//			}) { (err) in
//
//			}
//		}).disposed(by: self.disposeBag)
//	}
}

