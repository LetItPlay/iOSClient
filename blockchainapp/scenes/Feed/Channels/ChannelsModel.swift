//
//  ChannelsModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

enum ChannelScreen {
    case small, medium, full
}

protocol ChannelsModelProtocol: class, ModelProtocol {
    weak var delegate: ChannelsModelDelegate? {get set}
}

protocol ChannelsEventHandler: class {
//    func showChannel(index: Int)
    func refreshChannels()
    func followPressed()
}

protocol ChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
    func followUpdate(isSubscribed: Bool)
//    func showChannel(channel: FullChannelViewModel)
}

class ChannelsModel: ChannelsModelProtocol, ChannelsEventHandler {

    var channelScreen: ChannelScreen!
    
    weak var delegate: ChannelsModelDelegate?
    var subManager = SubscribeManager.shared
    var token: NotificationToken?
    
    var channels = [Station]()
    var currentChannelIndex: Int?
    
    init(channelScreen: ChannelScreen)
    {
        self.channelScreen = channelScreen
        
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
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
        
        var channelVMs = [SmallChannelViewModel]()
        
        switch channelScreen {
        case .small:
            for channel in channels
            {
                channelVMs.append(SmallChannelViewModel.init(channel: channel))
            }
        case .medium:
            for channel in channels
            {
                channelVMs.append(ChannelViewModel.init(channel: channel))
            }
        case .full:
            for channel in channels
            {
                channelVMs.append(FullChannelViewModel.init(channel: channel))
            }
        default:
            break
        }
        
        self.delegate?.reload(newChannels: channelVMs)
    }
    
    func refreshChannels() {
        self.getData { [weak self] (channels) in
            self?.getChannelViewModels(channels: channels.map({$0.detached()}))
        }
    }
    
//    func showChannel(index: Int) {
//        self.delegate?.showChannel(channel: FullChannelViewModel.init(channel: channels[index]))
//    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
    
    func followPressed() {
        subManager.addOrDelete(station: self.channels[currentChannelIndex!].id)
    }
}

extension ChannelsModel: SettingsUpdateProtocol, SubscriptionUpdateProtocol {
    func settingsUpdated() {
        self.getData { _ in
            
        }
    }
    
    func stationSubscriptionUpdated() {
        if self.channelScreen == .medium
        {
            self.refreshChannels()
        }
        else if self.channelScreen == .full
        {
            // TODO: change button title?
        }
    }
}
