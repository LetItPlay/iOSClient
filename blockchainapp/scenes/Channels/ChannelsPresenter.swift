//
//  ChannelsPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

class ChannelsPresenter: ChannelsPresenterProtocol {
    
    weak var view: ChannelsViewProtocol?
    
    var subManager = SubscribeManager.shared
    
    init(view: ChannelsViewProtocol) {
        self.view = view
    }
    
    //
    func getData(onComplete: @escaping StationResult) {
        DownloadManager.shared.requestChannels(success: { [weak self] (channels) in
            
            guard self != nil else {
                return
            }
            
            DispatchQueue.main.async {
                onComplete(channels)
            }
            
            let indexes = channels.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
            if !indexes.isEmpty {
                DispatchQueue.main.async {
                    self!.view?.select(rows: indexes)
                }
            }
        }) { (err) in
            
        }
    }
    
    func select(station: Station) {
        subManager.addOrDelete(station: station.id)
    }
}
