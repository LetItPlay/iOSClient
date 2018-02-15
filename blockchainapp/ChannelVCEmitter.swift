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
    
    weak var model: ChannelVCEvenHandler?
    
    convenience init(model: ChannelVCEvenHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
}
