//
//  ChannelsPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

class ChannelsPresenter: ChannelsPresenterProtocol {
    
    weak var view: ChannelsViewProtocol?
    
    var subManager = SubscribeManager.shared
    
    var token: NotificationToken?
    
    init(view: ChannelsViewProtocol) {
        self.view = view
        
        let realm = try! Realm()
        let results = realm.objects(Station.self)
        token = results.observe({ [weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                let items = Array(results.sorted(by: {$0.0.subscriptionCount > $0.1.subscriptionCount}))
                self?.view?.display(channels: items)
                
				let indexes = items.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
                if !indexes.isEmpty {
                    DispatchQueue.main.async {
                        self!.view?.select(rows: indexes)
                    }
                }
                
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                let items = Array(results.sorted(by: {$0.0.subscriptionCount > $0.1.subscriptionCount}))
                self?.view?.display(channels: items)
                
                let indexes = items.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
                if !indexes.isEmpty {
                    DispatchQueue.main.async {
                        self!.view?.select(rows: indexes)
                    }
                }
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
            
        })
    }
    
    //
    func getData(onComplete: @escaping StationResult) {
        DownloadManager.shared.requestChannels(success: { (channels) in
            
        }) { (err) in
            
        }
    }
    
    func select(station: Station) {
        subManager.addOrDelete(station: station.id)
    }
}
