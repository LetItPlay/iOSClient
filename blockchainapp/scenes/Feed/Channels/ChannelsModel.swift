//
//  ChannelsModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Action

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
	func showAllChannels()
}

protocol ChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
    func showChannel(id: Int)
	func showAllChannels()
}

class ChannelsModel: ChannelsModelProtocol, ChannelsEventHandler {

    var channelScreen: ChannelScreen!
    
    weak var delegate: ChannelsModelDelegate?
    var subManager = SubscribeManager.shared
	
	let getChannelsAction: Action<Bool, [Station1]>!
	let disposeBag = DisposeBag()
    var channels = [Station1]()
    
    init(channelScreen: ChannelScreen)
    {
        self.channelScreen = channelScreen
		
		self.getChannelsAction = Action<Bool, [Station1]>.init(workFactory: { (_) -> Observable<[Station1]> in
			return RequestManager.shared.channels()
		})
		
		self.getChannelsAction.elements.subscribe(onNext: { stations in
			self.channels = stations
			self.delegate?.reload(newChannels: self.channels.map({SmallChannelViewModel.init(channel: $0)}))
		}).disposed(by: disposeBag)
		
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
    
    func refreshChannels(){
        self.getChannelsAction.execute(true)
    }
    
    func subscribeAt(index: Int) {
        let channel = self.channels[index]
        subManager.addOrDelete(station: channel.id)
    }
    
    func showChannel(index: Int) {
        self.delegate?.showChannel(id: self.channels[index].id)
    }
	
	func showAllChannels() {
		self.delegate?.showAllChannels()
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
        self.getChannelsAction.execute(true)
    }
    
    func stationSubscriptionUpdated() {
        if self.channelScreen == .medium
        {
            self.refreshChannels()
        }
    }
}
