//
//  FeedPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyAudioManager
import RealmSwift

class FeedPresenter: FeedPresenterProtocol {	
    
    weak var view: FeedViewProtocol?
    let audioManager = AppManager.shared.audioManager
    
    var token: NotificationToken?
    
//    var playList = [PlayerItem]()
    
	var isFeed: Bool = false
	var tracks: [(Bool, Track)] = []
    
    init(view: FeedViewProtocol, orderByListens: Bool) {
        self.view = view
		
		self.isFeed = !orderByListens
        
        let realm = try! Realm()
        let results = orderByListens ? realm.objects(Track.self).sorted(byKeyPath: "listenCount", ascending: false)
            : realm.objects(Track.self).sorted(byKeyPath: "publishedAt", ascending: false)

        token = results.observe({ [weak self] (changes: RealmCollectionChange) in
			let filter: (Track) -> Bool = (self?.isFeed ?? false) ? {SubscribeManager.shared.stations.contains($0.station)} : {(_) -> Bool in return true }
			let currentID = AudioController.main.currentTrack?.id
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.tracks = Array(results).filter(filter).map({($0.id == currentID, $0)})
				
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                self?.tracks = Array(results).filter(filter).map({($0.id == currentID, $0)})
                
                if AppManager.shared.rootTabBarController?.selectedViewController !== (self!.view as! UIViewController).navigationController {
                    AppManager.shared.rootTabBarController?.tabBar.items?[2].badgeValue = insertions.isEmpty ? nil : "\(insertions.count)"
                }
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
			
			self?.view?.display()

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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
	
	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int, let index = self.tracks.index(where: {$0.1.id == id}) {
			self.tracks[index].0 = true
			self.view?.update(indexes: [index])
		}
	}
	
	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int, let index = self.tracks.index(where: {$0.1.id == id}) {
			self.tracks[index].0 = false
			self.view?.update(indexes: [index])
		}
	}
    
    @objc func subscriptionChanged(notification: Notification) {
        getData { (result) in
			
        }
    }
    
    func getData(onComplete: @escaping TrackResult) {
        
		DownloadManager.shared.requestTracks(all: !isFeed, success: { (feed) in
            
        }) { (err) in
            
        }
    }
    
    func play(trackUID: Int) {
        //TODO: fix this shet
//        if audioManager.currentItemId == trackUID {
//            if audioManager.isPlaying {
//                audioManager.pause()
//            } else {
//                audioManager.resume()
//            }
//        } else {
//            audioManager.playItem(with: trackUID)
//        }
		if trackUID != AudioController.main.currentTrack?.id {
			AudioController.main.loadPlaylist(playlist: (self.isFeed ? "Feed" : "Hot", self.tracks.map({$0.1})))
		}
		AudioController.main.make(command: .play(id: trackUID))
    }
    
    func like(trackUID: Int) {
        LikeManager.shared.addOrDelete(id: trackUID)
    }
}
