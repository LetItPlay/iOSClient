//
//  ChannelsViewModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsVMDelegate: class  {
    func reloadChannels()
}

class ChannelsViewModel: ChannelsModelDelegate {

    var channels: [ChannelViewModel] = []
    weak var delegate: ChannelsVMDelegate?
    
    func reload(newChannels: [ChannelViewModel]) {
        self.channels = newChannels
        self.delegate?.reloadChannels()
    }
}
