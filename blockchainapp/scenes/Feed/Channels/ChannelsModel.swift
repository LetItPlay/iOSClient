//
//  ChannelsModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum ChannelScreen {
    case small, medium
}

protocol ChannelsModelProtocol: class, ModelProtocol {
    weak var delegate: ChannelsModelDelegate? {get set}
}

protocol ChannelsEventHandler: class {
    func showChannel(index: Int)
    func getData()
    func subscribeAt(index: Int)
}

protocol ChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
    func showChannel(channel: FullChannelViewModel)
    func showChannel(station: Station1)
}

class ChannelsModel: ChannelsModelProtocol, ChannelsEventHandler {

    var channelScreen: ChannelScreen!
    
    weak var delegate: ChannelsModelDelegate?
    var subManager = SubscribeManager.shared
    var token: NotificationToken?
    
    var channels = [Station1]()
    
    let disposeBag = DisposeBag()
    
    init(channelScreen: ChannelScreen)
    {
        self.channelScreen = channelScreen
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
    
    func getData()
    {
        RequestManager.shared.channels().subscribe(onNext: { (channels) in
            self.channels = channels.sorted(by: { $0.subscriptionCount > $1.subscriptionCount })
            self.getChannelViewModels(channels: self.channels)
        }).disposed(by: self.disposeBag)
    }
    
    func getChannelViewModels(channels: [Station1])
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
    
    func subscribeAt(index: Int) {
        let channel = self.channels[index]
        let action: StationAction = channel.isSubscribed ? StationAction.unsubscribe : StationAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        
        // while in User Settings
        subManager.addOrDelete(station: self.channels[index].id)
        self.channels[index].isSubscribed = !self.channels[index].isSubscribed
        self.getData()
    }
    
    func showChannel(index: Int) {
        let stations: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
//        self.delegate?.showChannel(channel: FullChannelViewModel.init(channel: channels[index], isSubscribed: stations.contains(channels[index].id)))
        self.delegate?.showChannel(station: channels[index])
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.getData()
        case .appear:
            self.getData()
        default:
            break
        }
    }
}

extension ChannelsModel: SettingsUpdateProtocol, SubscriptionUpdateProtocol {
    func settingsUpdated() {
        self.getData()
    }
    
    func stationSubscriptionUpdated() {
        if self.channelScreen == .medium
        {
            self.getData()
        }
    }
}
