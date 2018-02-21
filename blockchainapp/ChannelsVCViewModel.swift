//
//  ChannelsVCViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsVCVMProtocol {
    var channels: [ChannelViewModel] {get}
    weak var delegate: ChannelsVCVMDelegate? {get set}
}

protocol ChannelsVCVMDelegate: class {
    func reloadChannels()
}

class ChannelsVCViewModel: ChannelsVCModelDelegate {
    
    var channels: [ChannelViewModel] = []
    weak var delegate: ChannelsVCVMDelegate?
    var model: ChannelsVCModelProtocol!
    
    init(model: ChannelsVCModelProtocol)
    {
        self.model = model
        self.model.delegate = self
    }
    
    func reload(newChannels: [ChannelViewModel]) {
        self.channels = newChannels
        self.delegate?.reloadChannels()
    }
    
    func showChannel(channel: FullChannelViewModel) {
        // TODO: to router
    }
}
