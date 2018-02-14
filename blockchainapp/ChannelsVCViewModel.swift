//
//  ChannelsVCViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsVCVMDelegate: class {
    func reloadChannels()
}

class ChannelsVCViewModel: ChannelsVCModelDelegate {
    
    var channels: [ChannelViewModel] = []
    weak var delegate: ChannelsVCVMDelegate?
    
    func reload(newChannels: [ChannelViewModel]) {
        self.channels = newChannels
        self.delegate?.reloadChannels()
    }
    
    func showChannel(channel: FullChannelViewModel) {
        // TODO: to router
    }
}
