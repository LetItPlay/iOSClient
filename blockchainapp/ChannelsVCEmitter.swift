//
//  ChannelsVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsVCEmitterProtocol {
    func showChannel(index: IndexPath)
    func refreshData()
}

class ChannelsVCEmitter: ChannelsVCEmitterProtocol {
    
    var model: ChannelsVCModelProtocol!
    
    init(model: ChannelsVCModelProtocol) {
        self.model = model
    }
    
    func showChannel(index: IndexPath) {
        self.model.showChannel(index: index)
    }
    
    func refreshData() {
        self.model.refreshChannels()
    }
}
