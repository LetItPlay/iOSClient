//
//  ChannelsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsEmitterProtocol: LifeCycleHandlerProtocol {
    func showChannel(index: Int)
}

class ChannelsEmitter: Emitter, ChannelsEmitterProtocol {
    weak var model: ChannelsEventHandler?
    
    convenience init(model: ChannelsEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func showChannel(index: Int) {
        self.model?.showChannel(index: index)
    }
}
