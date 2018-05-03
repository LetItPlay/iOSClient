//
//  MainChannelModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol MainChannelsModelProtocol: ModelProtocol {
    var delegate: MainChannelsModelDelegate? {get set}
}

protocol MainChannelsEventHandler: class {
    func showChannel(section: String, index: Int)
    func showAllChannelsFor(section: String)
}

protocol MainChannelsModelDelegate: class {
    func showChannel(id: Int)
    func showAllChannelsFor(category: String)
}

class MainChannelsModel: MainChannelsModelProtocol, MainChannelsEventHandler {
    var delegate: MainChannelsModelDelegate?
    
    var categories: [String : [Channel]]
    
    init() {
        // get categories
        categories = [:]
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
    
    func showAllChannelsFor(section: String) {
        self.delegate?.showAllChannelsFor(category: section)
    }
    
    func showChannel(section: String, index: Int) {
        self.delegate?.showChannel(id: categories[section]![index].id)
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
