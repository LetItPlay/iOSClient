//
//  ChannelsViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsVMProtocol {
    var channels: [SmallChannelViewModel] {get}
    
    weak var delegate: ChannelsVMDelegate? {get set}
}

protocol ChannelsVMDelegate: class  {
    func reloadChannels()
}

class ChannelsViewModel: ChannelsModelDelegate {

    var channels: [SmallChannelViewModel] = []
    weak var delegate: ChannelsVMDelegate?
    var model: ChannelsModelProtocol!
    
    init(model: ChannelsModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func reload(newChannels: [SmallChannelViewModel]) {
        self.channels = newChannels
        self.delegate?.reloadChannels()
    }
    
    func showChannel(channel: FullChannelViewModel) {
        // TODO: to router
    }
}
