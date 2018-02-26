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
        
//        let realm = try! Realm()
//        let results = realm.objects(Station.self)
//        token = results.observe({ [weak self] (changes: RealmCollectionChange) in
//
//            switch changes {
//            case .initial:
//                // Results are now populated and can be accessed without blocking the UI
//                let items = Array(results.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})).filter({$0.lang == UserSettings.language.rawValue})
//                self?.view?.display(channels: items.map({$0.detached()}))
//
//                let indexes = items.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
//                if !indexes.isEmpty {
//                    DispatchQueue.main.async {
//                        self!.view?.select(rows: indexes)
//                    }
//                }
//            case .update(_, _, let ins, _):
//                // Query results have changed, so apply them to the UITableView
//                let items = Array(results.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})).filter({$0.lang == UserSettings.language.rawValue})
//                if items.count != 0 && ins.count != 0 {
//                    self?.view?.display(channels: items.map({$0.detached()}))
//
//                    let indexes = items.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
//                    if !indexes.isEmpty {
//                        DispatchQueue.main.async {
//                            self!.view?.select(rows: indexes)
//                        }
//                    }
//                }
//
//            case .error(let error):
//                // An error occurred while opening the Realm file on the background worker thread
//                fatalError("\(error)")
//            }
//
//        })
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(settingsChanged(notification:)),
//                                               name: SettingsNotfification.changed.notification(),
//                                               object: nil)
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		token?.invalidate()
	}
	
	@objc func settingsChanged(notification: Notification) {
		self.getData { _ in
			
		}
	}
	
	
    
    //
    func getData(onComplete: @escaping ChannelResult) {
        DownloadManager.shared.requestChannels(success: { (channels) in
            
        }) { (err) in
            
        }
    }
    
    func select(channel: Channel) {
        subManager.addOrDelete(channel: channel.id)
    }
}
