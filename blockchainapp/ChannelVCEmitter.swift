//
//  ChannelVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelVCEmitterProtocol {
    func getTracks()
}

class ChannelVCEmitter: ChannelVCEmitterProtocol {
    
    var model: ChannelVCModelProtocol!
    
    init(model: ChannelVCModelProtocol)
    {
        self.model = model
    }
    
    func getTracks() {
        self.model.getTracks()
    }
}
