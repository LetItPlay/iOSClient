//
//  ChannelsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsEmitterProtocol: LifeCycleHandlerProtocol {
    func showChannel(index: IndexPath)
}

class ChannelsEmitter: Emitter, ChannelsEmitterProtocol {
    
    var model: ChannelsModelProtocol!
    
    convenience init(model: ChannelsModelProtocol) {
        self.init(handler: model)
        self.model = model
    }
    
    func showChannel(index: IndexPath) {
        self.model.showChannel(index: index)
    }
}
