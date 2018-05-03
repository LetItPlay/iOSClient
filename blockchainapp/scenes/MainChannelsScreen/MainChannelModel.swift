//
//  MainChannelModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import Action

protocol MainChannelsModelProtocol: ModelProtocol {
    var delegate: MainChannelsModelDelegate? {get set}
}

protocol MainChannelsEventHandler: class {
    func showChannel(section: Int, index: Int)
    func showAllChannelsFor(section: Int)
    func refresh()
}

protocol MainChannelsModelDelegate: class {
    func reload(categories: [ChannelCategoryViewModel])
    func showChannel(id: Int)
    func showAllChannelsFor(category: String)
}

class MainChannelsModel: MainChannelsModelProtocol, MainChannelsEventHandler {
    var delegate: MainChannelsModelDelegate?
    
    var categories: [String : [Channel]] = [:]
    
    let getChannelsAction: Action<Bool, [Channel]>!
    var disposeBag = DisposeBag()
    
    init() {
        
        self.getChannelsAction = Action<Bool, [Channel]>.init(workFactory: { (_) -> Observable<[Channel]> in
            return RequestManager.shared.channels()
        })
        
        self.getChannelsAction.elements.subscribe(onNext: { channels in
            self.categories = ["Auto" : Array(channels[0...3]), "Some others" : Array(channels[6...13])]
            self.delegate?.reload(categories: self.getChannelsCategories())
        }).disposed(by: disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func getChannelsCategories() -> [ChannelCategoryViewModel] {
        var channelCategories: [ChannelCategoryViewModel] = []
        for category in self.categories {
            channelCategories.append(ChannelCategoryViewModel(name: category.key, channels: category.value.map({CategoryChannelViewModel(channel: $0)})))
        }
        return channelCategories
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.refresh()
        default:
            break
        }
    }
    
    func showAllChannelsFor(section: Int) {
        let channelsCategories = self.getChannelsCategories()
        self.delegate?.showAllChannelsFor(category: channelsCategories[section].name)
    }
    
    func showChannel(section: Int, index: Int) {
        let channelsCategories = self.getChannelsCategories()
        self.delegate?.showChannel(id: categories[channelsCategories[section].name]![index].id)
    }
    
    func refresh() {
        self.getChannelsAction.execute(true)
    }
}

extension MainChannelsModel: ChannelUpdateProtocol {
    func channelUpdated(channel: Channel) {
//        if let index = self.channels.index(where: {$0.id == channel.id}) {
//            self.channels[index] = channel
//            self.delegate?.update(index: index, vm: self.channelScreen == .small ? SmallChannelViewModel(channel: self.channels[index]) : MediumChannelViewModel(channel: self.channels[index]))
//        }
    }
}
