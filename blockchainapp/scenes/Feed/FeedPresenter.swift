//
//  FeedPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyAudioManager

class FeedPresenter: FeedPresenterProtocol {
    
    weak var view: FeedViewProtocol?
    let audioManager = AppManager.shared.audioManager
    
    var playList = [PlayerItem]()
    
    init(view: FeedViewProtocol) {
        self.view = view
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subscriptionChanged(notification:)),
                                               name: SubscribeManager.NotificationName.added.notification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subscriptionChanged(notification:)),
                                               name: SubscribeManager.NotificationName.deleted.notification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func subscriptionChanged(notification: Notification) {
        getData { [weak self] (result) in
            self?.view?.display(tracks: result)
        }
    }
    
    func getData(onComplete: @escaping TrackResult) {
        DownloadManager.shared.requestTracks(success: { [weak self] (feed) in
            
            guard self != nil else {
                return
            }
            
            self?.playList = [PlayerItem]()
            
            for f in feed {
                let playerItem = PlayerItem(itemId: f.uniqString(),
                                            url: f.audiofile.file.buildImageURL()?.absoluteString ?? "")
                playerItem.autoLoadNext = true
                playerItem.autoPlay = true
                
                self?.playList.append(playerItem)
            }
            
            if !self!.playList.isEmpty {
                self?.audioManager.resetPlaylistAndStop()
                let group = PlayerItemsGroup(id: "120", name: "main", playerItems: self!.playList)
                self?.audioManager.add(playlist: [group])
            }
            
            DispatchQueue.main.async {
                onComplete(feed)
                
                if AppManager.shared.rootTabBarController?.selectedViewController !== (self!.view as! UIViewController).navigationController {
                    AppManager.shared.rootTabBarController?.tabBar.items?[2].badgeValue = feed.isEmpty ? nil : "New"
                }
            }
        }) { (err) in
            
        }
    }
    
    func play(track: Track) {
        if audioManager.playlist == nil {
            if playList.isEmpty {
                
            } else {
                let group = PlayerItemsGroup(id: "120", name: "main", playerItems: playList)
                audioManager.add(playlist: [group])
            }
        } else
        if audioManager.currentItemId == track.uniqString() {
            if audioManager.isPlaying {
                audioManager.pause()
            } else {
                audioManager.resume()
            }
        } else {
            audioManager.playItem(with: track.uniqString())
        }
        
    }
}
