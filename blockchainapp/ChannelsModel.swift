//
//  ChannelsModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChannelsModelProtocol {
//    func getChannels()
}

protocol ChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
}

class ChannelsModel: ChannelsModelProtocol {

    weak var delegate: ChannelsModelDelegate?
    var subManager = SubscribeManager.shared
    var token: NotificationToken?
    
    var channels = [Station]()
    
    init()
    {
        let realm = try! Realm()
        let results = realm.objects(Station.self)
        token = results.observe({ [weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.channels = Array(results.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})).filter({$0.lang == UserSettings.language.rawValue})
//                self?.view?.display(channels: items)
                self?.getChannelViewModels()
                
                let indexes = self?.channels.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
                if !(indexes?.isEmpty)! {
                    DispatchQueue.main.async {
//                        self!.view?.select(rows: indexes)
                    }
                }
                
            case .update(_, _, _, _):
                // Query results have changed, so apply them to the UITableView
                self?.channels = Array(results.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})).filter({$0.lang == UserSettings.language.rawValue})
//                self?.view?.display(channels: items)
                self?.getChannelViewModels()
                
                let indexes = self?.channels.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
                if !(indexes?.isEmpty)! {
                    DispatchQueue.main.async {
//                        self!.view?.select(rows: indexes)
                    }
                }
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
            
        })
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
        self.getData { _ in
            
        }
    }
    
    func getData(onComplete: @escaping StationResult) {
        DownloadManager.shared.requestChannels(success: { (channels) in
            
        }) { (err) in
            
        }
    }
    
    func select(station: Station) {
        subManager.addOrDelete(station: station.id)
    }
    
    func getChannelViewModels()
    {
        var channelVMs = [SmallChannelViewModel]()
        for channel in channels
        {
            channelVMs.append(SmallChannelViewModel.init(channel: channel))
        }
        
        self.delegate?.reload(newChannels: channelVMs)
    }
    
//    func getChannels() {
//
//    }
}
