//
//  FeedPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
 
import RealmSwift
import RxSwift

class FeedPresenter: FeedPresenterProtocol {	
    
    weak var view: FeedViewProtocol?
    
    var token: NotificationToken?
    
//    var playList = [PlayerItem]()
    
	var isFeed: Bool = false
	var tracks: [Track] = []
	var playingIndex: Int = -1
	
	var sort: (Track, Track) -> Bool? = {_,_ in return nil}
    
    init(view: FeedViewProtocol, orderByListens: Bool) {
        self.view = view
		
		self.isFeed = !orderByListens
        
        let realm = try! Realm()
//		var sortDescriptors: [SortDescriptor] = []
//		if orderByListens {
//			sortDescriptors.append(SortDescriptor.init(keyPath: "listenCount", ascending: true))
//		} else {
//			sortDescriptors.append(SortDescriptor.init(keyPath: "publishedAt", ascending: true))
//		}
//		sortDescriptors.append(SortDescriptor.init(keyPath: "name", ascending: true))
		
		if (self.isFeed) {
			sort = { first, second in
				if first.publishedAt != second.publishedAt {
					return first.publishedAt > second.publishedAt
				}
				return nil}
		} else {
			sort = {$0.listenCount != $1.listenCount ? $0.listenCount > $1.listenCount : nil}
		}
		let date = Date().addingTimeInterval(-60*60*24*7)
		let results = orderByListens ? realm.objects(Track.self).filter("publishedAt >= %@", date) : realm.objects(Track.self) //.sorted(by: sortDescriptors)

        token = results.observe({ [weak self] (changes: RealmCollectionChange) in
			let filter: (Track) -> Bool = (self?.isFeed ?? false) ? {SubscribeManager.shared.stations.contains($0.station) && $0.lang == UserSettings.language.rawValue} : {$0.lang == UserSettings.language.rawValue}
			let _ = AudioController.main.currentTrack?.id
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
				self?.tracks = Array(results).filter(filter).sorted(by: { (first, second) -> Bool in
					if let res = self?.sort(first, second) {
						return res
					} else {
						return first.name < second.name
					}
				}).map({$0})
				
				self?.view?.display()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                let oldTracks = self?.tracks.count ?? 0
				self?.tracks = Array(results).filter(filter).sorted(by: { (first, second) -> Bool in
					if let res = self?.sort(first, second) {
						return res
					} else {
						return first.name < second.name
					}
				}).map({$0})
                
                if AppManager.shared.rootTabBarController?.selectedViewController !== (self!.view as! UIViewController).navigationController && self?.isFeed == true {
                    let new = (self?.tracks.count ?? 0) - oldTracks
                    AppManager.shared.rootTabBarController?.tabBar.items?[0].badgeValue = new == 0 ? nil : "\(new)"
                }
				let update = modifications.map({ (index) -> Int? in
					return self?.tracks.index(where: {$0.id == results[index].id})
				}).filter({$0 != nil}).map({$0!})
				let delete = deletions.map({ (index) -> Int? in
					return self?.tracks.index(where: {$0.id == results[index].id})
				}).filter({$0 != nil}).map({$0!})
				let insert = insertions.map({ (index) -> Int? in
					return self?.tracks.index(where: {$0.id == results[index].id})
				}).filter({$0 != nil}).map({$0!})
				self?.view?.reload(update: update, delete: delete, insert: insert)
				
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        })
        
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
											   object: nil)    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
	
	@objc func settingsChanged(notification: Notification) {
		self.playingIndex = -1
		self.getData { _ in

		}
	}
	
	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
			var reload = [Int]()
			if playingIndex != -1 {
				reload.append(playingIndex)
			}
			reload.append(index)
			self.playingIndex = index
			self.view?.reload(update: reload, delete: [], insert: [])
		}
	}
	
	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
			var reload = [Int]()
			if playingIndex != -1 {
				reload.append(playingIndex)
			}
			self.playingIndex = -1
			self.view?.reload(update: reload, delete: [], insert: [])
		}
	}
    
    @objc func subscriptionChanged(notification: Notification) {
        getData { (result) in
			
        }
    }
	
	let disposeBag = DisposeBag()
	
    func getData(onComplete: @escaping TrackResult) {
		DownloadManager.shared.channelsSignal().observeOn(MainScheduler.init()).subscribe( onCompleted: {
			DownloadManager.shared.requestTracks(all: !self.isFeed, success: { (feed) in
				
			}) { (err) in
				
			}
		}).disposed(by: self.disposeBag)
    }
	
	func play(index: Int) {
		if index < self.tracks.count {
			let trackUID = self.tracks[index].audiotrackId()
			let name = self.isFeed ? "Feed".localized : "Trends".localized
			AudioController.main.loadPlaylist(playlist: (name, self.tracks.map({$0.audioTrack()})), playId: trackUID)
		}
	}
	
	func like(index: Int) {
		if index < self.tracks.count {
			LikeManager.shared.addOrDelete(id: self.tracks[index].id)
		}
	}
	
	func addTrack(toBeggining: Bool, for index: Int) {
		
	}
    
    func like(trackUID: Int) {
        LikeManager.shared.addOrDelete(id: trackUID)
    }
}
