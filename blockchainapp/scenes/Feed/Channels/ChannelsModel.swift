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

protocol ChannelsModelProtocol: ModelProtocol {
    weak var delegate: ChannelsModelDelegate? {get set}
}

protocol ChannelsEventHandler: class {
    func showChannel(index: Int)
    func subscribeAt(index: Int)
	func refreshChannels()
	func showAllChannels()
}

protocol ChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
    func showChannel(id: Int)
	func showAllChannels()
    func update(index: Int, vm: SmallChannelViewModel)
}

class ChannelsModel: ChannelsModelProtocol, ChannelsEventHandler {

    var channelScreen: ChannelScreen!
    
    weak var delegate: ChannelsModelDelegate?
    var subManager = SubscribeManager.shared
	var channels: [Channel] = []
	
	let getChannelsAction: Action<Bool, [Channel]>!
	let disposeBag = DisposeBag()
    
    init(channelScreen: ChannelScreen)
    {
        self.channelScreen = channelScreen
	
		self.getChannelsAction = Action<Bool, [Channel]>.init(workFactory: { (_) -> Observable<[Channel]> in
			return RequestManager.shared.channels()
		})
		
		self.getChannelsAction.elements.subscribe(onNext: { channels in
            self.channels = channels.filter({$0.lang == UserSettings.language.rawValue})
			self.channels = self.channels.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})
			self.delegate?.reload(newChannels: self.channels.map({self.channelScreen == .small ? SmallChannelViewModel.init(channel: $0) : MediumChannelViewModel.init(channel: $0)}))
		}).disposed(by: disposeBag)
		
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
	
	func subscribeAt(index: Int) {
        let channel = self.channels[index]
        let action: ChannelAction = channel.isSubscribed ? ChannelAction.unsubscribe : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        
        // while in User Settings
        subManager.addOrDelete(channel: self.channels[index].id)
    }
    
    func showChannel(index: Int) {
        self.delegate?.showChannel(id: channels[index].id)
    }
	
	func showAllChannels() {
		self.delegate?.showAllChannels()
	}
	
	func refreshChannels() {
		self.getChannelsAction.execute(true)
	}
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.getChannelsAction.execute(true)
        default:
            break
        }
    }
}

extension ChannelsModel: SettingsUpdateProtocol, ChannelUpdateProtocol {
    func settingsUpdated() {
        self.getChannelsAction.execute(true)
    }
    
    func channelUpdated(channel: Channel) {
        if let index = self.channels.index(where: {$0.id == channel.id}) {
            self.channels[index] = channel
            self.delegate?.update(index: index, vm: self.channelScreen == .small ? SmallChannelViewModel(channel: self.channels[index]) : MediumChannelViewModel(channel: self.channels[index]))
        }
    }
}
