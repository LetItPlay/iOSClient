//
//  FeedPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

class FeedPresenter: FeedPresenterProtocol {
    
    weak var view: FeedViewProtocol?
    
    init(view: FeedViewProtocol) {
        self.view = view
    }
    
    func getData(onComplete: @escaping TrackResult) {
        DownloadManager.shared.requestTracks(success: { (feed) in
            DispatchQueue.main.async {
                onComplete(feed)
            }
        }) { (err) in
            
        }
    }
}
