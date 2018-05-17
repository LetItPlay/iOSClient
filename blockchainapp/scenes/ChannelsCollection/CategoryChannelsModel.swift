//
//  CategoryChannelsModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Action

enum ChannelScreen {
    case small, full, recentAdded
}

enum ChannelsFilter {
    case subscribed, all, category(Int, String), hidden
}

protocol  CategoryChannelsModelProtocol: ModelProtocol {
    var delegate:  CategoryChannelsModelDelegate? {get set}
}

protocol CategoryChannelsEventHandler: class {
    func showChannel(index: Int)
    func subscribeAt(index: Int)
    func refreshChannels()
    func showAllChannels()
    func showSearch(text: String?)
    func selected(tag: String)
}

protocol  CategoryChannelsModelDelegate: class {
    func reload(newChannels: [SmallChannelViewModel])
    func showChannel(id: Int)
    func update(index: Int, vm: SmallChannelViewModel)
    func showAllChannels()
    func set(category: String)
    func updateEmptyMessage(hide: Bool)
    func showSearch(text: String?)
}

class CategoryChannelsModel:  CategoryChannelsModelProtocol, CategoryChannelsEventHandler {
    
    var channelScreen: ChannelScreen!
    var channelsFilter: ChannelsFilter!
    
    var category: String = ""
    
    weak var delegate:  CategoryChannelsModelDelegate?
    var channels: [Channel] = []
    
    let getChannelsAction: Action<Bool, [Channel]>!
    let disposeBag = DisposeBag()
    
    init(channelScreen: ChannelScreen, channelsFilter: ChannelsFilter)
    {
        self.channelScreen = channelScreen
        self.channelsFilter = channelsFilter
        
        self.getChannelsAction = Action<Bool, [Channel]>.init(workFactory: { (_) -> Observable<[Channel]> in
            let request: ChannelsRequest!
            switch channelsFilter {
            case .all:
                request = ChannelsRequest.all(offset: 0, count: 100)
            case .category(let id, _):
                request = ChannelsRequest.category(id: id)
            case .subscribed:
                request = ChannelsRequest.subscribed
            case .hidden:
                request = ChannelsRequest.blacklist
            }
            
            return RequestManager.shared.channels(req: request)
        })
        
        self.getChannelsAction.elements.subscribe(onNext: { channels in
            self.channels = channels.filter({$0.lang == UserSettings.language.identifier})
            switch self.channelsFilter! {
            case .all:
                self.channels = self.channels.sorted(by: {$0.subscriptionCount > $1.subscriptionCount})
                self.category = LocalizedStrings.TabBar.channels
            case .hidden:
                self.channels = self.channels.map({ (channel) -> Channel in
                    var newChannel = channel
                    newChannel.isHidden = true
                    return newChannel
                })
                self.category = LocalizedStrings.Channels.hidden
            case .subscribed:
                self.category = LocalizedStrings.Channels.subscibedTitle
            case .category(_, let title):
                self.category = title
            }
            
            self.delegate?.set(category: self.category)
            self.delegate?.updateEmptyMessage(hide: self.channels.count == 0 ? false : true)
            self.delegate?.reload(newChannels: self.channels.map({self.channelScreen == .small ? SmallChannelViewModel.init(channel: $0) : MediumChannelViewModel.init(channel: $0)}))
        }).disposed(by: disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func subscribeAt(index: Int) {
        let channel = self.channels[index]
        let action: ChannelAction = channel.isHidden ? ChannelAction.showHidden : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)        
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
    
    func selected(tag: String) {
        self.showSearch(text: tag)
    }
    
    func showSearch(text: String?) {
        self.delegate?.showSearch(text: text)
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

extension CategoryChannelsModel: SettingsUpdateProtocol, ChannelUpdateProtocol {
    func settingsUpdated() {
        self.getChannelsAction.execute(true)
    }
    
    func gen(_ ch: Channel) -> SmallChannelViewModel {
        return self.channelScreen == .small ? SmallChannelViewModel(channel: ch) : MediumChannelViewModel(channel: ch)
    }
    
    func channelUpdated(channel: Channel) {
        if self.channelScreen != .small {
            switch self.channelsFilter! {
            case .hidden:
                if channel.isHidden {
                    if let index = self.channels.index(where: {$0.id == channel.id}) {
                        self.channels[index] = channel
                    } else {
                        self.channels.append(channel)
                    }
                } else {
                    if let index = self.channels.index(where: {$0.id == channel.id}) {
                        self.channels.remove(at: index)
                    }
                }
                self.delegate?.reload(newChannels: self.channels.map({self.channelScreen == .small ? SmallChannelViewModel.init(channel: $0) : MediumChannelViewModel.init(channel: $0)}))

            default:
                if let index = self.channels.index(where: {$0.id == channel.id}) {
                    self.channels[index] = channel
                    self.delegate?.update(index: index, vm: self.channelScreen == .small ? SmallChannelViewModel(channel: self.channels[index]) : MediumChannelViewModel(channel: self.channels[index]))
                }
            }
        } else {
            if let index = self.channels.index(where: {$0.id == channel.id}) {
                if !channel.isSubscribed {
                    self.channels.remove(at: index)
                }
            } else {
                if channel.isSubscribed {
                    self.channels.insert(channel, at: 0)
                }
            }
            self.delegate?.reload(newChannels: self.channels.map({self.gen($0)}))
        }
    }
}
