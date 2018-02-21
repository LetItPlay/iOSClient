//
//  ChannelsEmitter.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsEmitterProtocol {
    func state(_ state: LifeCycleEvent)
}

class ChannelsEmitter: ChannelsEmitterProtocol {
    
    var model: ChannelsModelProtocol!
    
    init(model: ChannelsModelProtocol) {
        self.model = model
    }
    
    func state(_ state: LifeCycleEvent) {
        switch state {
//        case .initialize:
//            self.model.getChannels()
        default:
            break
        }
    }
}
