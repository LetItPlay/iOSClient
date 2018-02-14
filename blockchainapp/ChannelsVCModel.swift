//
//  ChannelsVCModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChannelsVCModelProtocol {
    func showChannel(index: IndexPath)
    func refreshChannels()
}

protocol ChannelsVCModelDelegate: class {
    func reload(newChannels: [ChannelViewModel])
    func showChannel(channel: FullChannelViewModel)
}

class ChannelsVCModel: ChannelsVCModelProtocol {
    
    weak var delegate: ChannelsVCModelDelegate?
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
                let items = Array(results.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})).filter({$0.lang == UserSettings.language.rawValue})
                self?.getChannelViewModels(channels: items.map({$0.detached()}))
                
                let indexes = items.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
                if !indexes.isEmpty {
                    DispatchQueue.main.async {
                        //                        self!.view?.select(rows: indexes)
                    }
                }
            case .update(_, _, let ins, _):
                // Query results have changed, so apply them to the UITableView
                let items = Array(results.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})).filter({$0.lang == UserSettings.language.rawValue})
                if items.count != 0 && ins.count != 0 {
                    self?.getChannelViewModels(channels: items.map({$0.detached()}))
                    let indexes = items.enumerated().flatMap({ (n, e) in return self!.subManager.hasStation(id: e.id) ? n : nil })
                    if !indexes.isEmpty {
                        DispatchQueue.main.async {
                            //                            self!.view?.select(rows: indexes)
                        }
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
    
    func getChannelViewModels(channels: [Station])
    {
        self.channels = channels
        
        var channelVMs = [ChannelViewModel]()
        for channel in channels
        {
            channelVMs.append(ChannelViewModel.init(channel: channel))
        }
        
        self.delegate?.reload(newChannels: channelVMs)
    }
    
    func refreshChannels() {
        self.getData { [weak self] (channels) in
            self?.getChannelViewModels(channels: channels.map({$0.detached()}))
        }
    }
    
    func showChannel(index: IndexPath) {
        
    }
}
