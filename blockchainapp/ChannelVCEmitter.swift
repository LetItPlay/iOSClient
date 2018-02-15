//
//  ChannelVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelVCEmitterProtocol: LifeCycleHandlerProtocol {
}

class ChannelVCEmitter: Emitter, ChannelVCEmitterProtocol {
    
    var model: ChannelVCModelProtocol!
    
    convenience init(model: ChannelVCModelProtocol)
    {
        self.init(handler: model)
        self.model = model
    }
}
