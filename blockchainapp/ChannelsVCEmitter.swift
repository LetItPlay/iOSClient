//
//  ChannelsVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ChannelsVCEvent {
    case showChannel(index: IndexPath)
    case refreshData
}

protocol ChannelsVCEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: ChannelsVCEvent)
}

class ChannelsVCEmitter: Emitter, ChannelsVCEmitterProtocol {
    
    var model: ChannelsVCModelProtocol!
    
    convenience init(model: ChannelsVCModelProtocol) {
        self.init(handler: model)
        self.model = model
    }
    
    func send(event: ChannelsVCEvent) {
        switch event {
        case .refreshData:
            self.model.refreshChannels()
        case .showChannel(let index):
            self.model.showChannel(index: index)
        }
    }
}
