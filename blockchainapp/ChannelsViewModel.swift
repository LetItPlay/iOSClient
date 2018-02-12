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

    var channels: [Station] = []
    weak var delegate: ChannelsVMDelegate?
    
    func reloadChannels(newChannels: [Station]) {
        self.channels = newChannels
        self.delegate?.reloadChannels()
    }
}
