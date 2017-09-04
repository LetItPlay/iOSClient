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
    
    init(view: FeedViewProtocol) {
        self.view = view
    }
    
    func getData(onComplete: @escaping TrackResult) {
        DownloadManager.shared.requestTracks(success: { [weak self] (feed) in
            var playList = [PlayerItem]()
            
            for f in feed {
                let playerItem = PlayerItem(itemId: f.name,
                                            url: f.audiofile.file.buildImageURL()?.absoluteString ?? "")
                playerItem.autoLoadNext = true
                
                playList.append(playerItem)
            }
            
            let group = PlayerItemsGroup(id: "120", name: "main", playerItems: playList)
            self?.audioManager.add(playlist: [group])
            
            DispatchQueue.main.async {
                onComplete(feed)
            }
        }) { (err) in
            
        }
    }
    
    func play(track: Track) {
        audioManager.playItem(with: track.name)
    }
}
