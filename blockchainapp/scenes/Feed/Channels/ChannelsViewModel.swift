//
//  ChannelsViewModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsVMProtocol {
    var channels: [SmallChannelViewModel] {get}
    
    weak var delegate: ChannelsVMDelegate? {get set}
}

protocol ChannelsVMDelegate: class  {
    func reloadChannels()
    func showChannel(channel: Channel1)
}

class ChannelsViewModel: ChannelsVMProtocol, ChannelsModelDelegate {
    
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
    
	func showChannel(id: Int) {
		MainRouter.shared.show(screen: "channel", params: ["id": id], present: false)
	}
	
	func showAllChannels() {
		MainRouter.shared.show(screen: "allChannels", params: [:], present: false)
	}
    
    func showChannel(channel: Channel1) {
        self.delegate?.showChannel(channel: channel)
    }
    
    func update(index: Int, vm: SmallChannelViewModel) {
        self.channels[index] = vm
        self.delegate?.reloadChannels()
    }
}
