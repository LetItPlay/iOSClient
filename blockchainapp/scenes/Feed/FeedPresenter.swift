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
    
    var playList = [PlayerItem]()
    
    private var startTime: Double = 0
    
    init(view: FeedViewProtocol) {
        self.view = view
        
        let realm = try! Realm()
        let results = realm.objects(Track.self)
        token = results.addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                let items = Array(results)
                self?.view?.display(tracks:  items,
                                    deletions: [],
                                    insertions: [],
                                    modifications: [])
                self?.updatePlayList(feed: items,
                                     deletions: [],
                                     insertions: [],
                                     modifications: [])
                
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                let items = Array(results)
                self?.view?.display(tracks: items,
                                    deletions: deletions,
                                    insertions: insertions,
                                    modifications: modifications)
                self?.updatePlayList(feed: items,
                                     deletions: deletions,
                                     insertions: insertions,
                                     modifications: modifications)
                
                if AppManager.shared.rootTabBarController?.selectedViewController !== (self!.view as! UIViewController).navigationController {
                    AppManager.shared.rootTabBarController?.tabBar.items?[2].badgeValue = insertions.isEmpty ? nil : "\(insertions.count)"
                }
                
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
                                               selector: #selector(audioManagerStartPlay(notification:)),
                                               name: AudioManagerNotificationName.startPlaying.notification,
                                               object: audioManager)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.stop()
    }
    
    @objc func subscriptionChanged(notification: Notification) {
        getData { (result) in
            
        }
    }
    
    @objc func audioManagerStartPlay(notification: Notification) {
        if startTime != 0 {
            audioManager.itemProgressPercent = startTime
            startTime = 0
        }
    }
    
    private func updatePlayList(feed: [Track], deletions: [Int], insertions: [Int], modifications: [Int]) {
        if deletions.isEmpty && insertions.isEmpty && modifications.isEmpty ||
            !deletions.isEmpty ||
            !insertions.isEmpty {
            playList = [PlayerItem]()
            
            for f in feed {
                let playerItem = PlayerItem(itemId: f.uniqString(),
                                            url: f.audiofile?.file.buildImageURL()?.absoluteString ?? "")
                playerItem.autoLoadNext = true
                playerItem.autoPlay = true
                
                playList.append(playerItem)
            }
            
            startTime = 0
            
            if !playList.isEmpty {
                
                var currentId: String? = nil
                
                if audioManager.isPlaying {
                    currentId = audioManager.currentItemId
                    startTime = audioManager.itemProgressPercent
                }
                
                audioManager.resetPlaylistAndStop()
                let group = PlayerItemsGroup(id: "120", name: "main", playerItems: playList)
                audioManager.add(playlist: [group])
                
                if currentId != nil {
                    audioManager.playItem(with: currentId!)
                }
            }
        }
    }
    
    func getData(onComplete: @escaping TrackResult) {
        
        DownloadManager.shared.requestTracks(success: { (feed) in
            
        }) { (err) in
            
        }
    }
    
    func play(trackUID: String) {
        if audioManager.playlist == nil {
            if playList.isEmpty {
                
            } else {
                let group = PlayerItemsGroup(id: "120", name: "main", playerItems: playList)
                audioManager.add(playlist: [group])
            }
        } else
        if audioManager.currentItemId == trackUID {
            if audioManager.isPlaying {
                audioManager.pause()
            } else {
                audioManager.resume()
            }
        } else {
            audioManager.playItem(with: trackUID)
        }
        
    }
    
    func like(trackUID: Int) {
        LikeManager.shared.addOrDelete(id: trackUID)
    }
}
