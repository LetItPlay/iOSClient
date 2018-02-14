//
//  ChannelsViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
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
