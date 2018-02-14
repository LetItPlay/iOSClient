//
//  ChannelsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsEmitterProtocol {
    func showChannel(index: IndexPath)
}

class ChannelsEmitter: ChannelsEmitterProtocol {
    
    var model: ChannelsModelProtocol!
    
    init(model: ChannelsModelProtocol) {
        self.model = model
    }
    
    func showChannel(index: IndexPath) {
        self.model.showChannel(index: index)
    }
}
