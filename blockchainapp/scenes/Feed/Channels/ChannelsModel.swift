//
//  ChannelsModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

enum ChannelScreen {
    case small, medium
}

protocol ChannelsModelProtocol: class, ModelProtocol {
    weak var delegate: ChannelsModelDelegate? {get set}
}

protocol ChannelsEventHandler: class {
    func showChannel(index: Int)
    func refreshChannels()
    func subscribeAt(index: Int)
}

protocol ChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
    func showChannel(channel: FullChannelViewModel)
}

class ChannelsModel: ChannelsModelProtocol, ChannelsEventHandler {

    var channelScreen: ChannelScreen!
    
    weak var delegate: ChannelsModelDelegate?
    var subManager = SubscribeManager.shared
    var token: NotificationToken?
    
    var channels = [Station]()
    
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
            let stations: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
            
            for channel in channels
            {
                channelVMs.append(MediumChannelViewModel.init(channel: channel, isSubscribed: stations.contains(channel.id)))
            }
        default:
            break
        }
        
        self.delegate?.reload(newChannels: channelVMs)
    }
    
    func refreshChannels(){
        self.getData { [weak self] (channels) in
            self?.getChannelViewModels(channels: channels.map({$0.detached()}))
        }
    }
    
    func subscribeAt(index: Int) {
        let channel = self.channels[index]
//        let action: StationAction = channel.isSubscribed ? Station.unlike : TrackAction.like
//        ServerUpdateManager.shared.makeStation(id: channel.id, action: .subscribe)
        subManager.addOrDelete(station: channel.id)
    }
    
    func showChannel(index: Int) {
        let stations: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
        self.delegate?.showChannel(channel: FullChannelViewModel.init(channel: channels[index], isSubscribed: stations.contains(channels[index].id)))
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.refreshChannels()
        case .appear:
            self.refreshChannels()
        default:
            break
        }
    }
}

extension ChannelsModel: SettingsUpdateProtocol, SubscriptionUpdateProtocol {
    func settingsUpdated() {
        self.refreshChannels()
    }
    
    func stationSubscriptionUpdated() {
        if self.channelScreen == .medium
        {
            self.refreshChannels()
        }
    }
}
