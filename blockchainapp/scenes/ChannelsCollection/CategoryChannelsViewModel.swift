//
//  CategoryChannelsViewModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol CategoryChannelsVMProtocol {
    var channels: [SmallChannelViewModel] {get}
    
    var delegate: CategoryChannelsVMDelegate? {get set}
}

protocol CategoryChannelsVMDelegate: class  {
    func reloadChannels()
}

class CategoryChannelsViewModel: CategoryChannelsVMProtocol,  CategoryChannelsModelDelegate {
    
    var channels: [SmallChannelViewModel] = []
    weak var delegate: CategoryChannelsVMDelegate?
    var model:  CategoryChannelsModelProtocol!
    
    init(model:  CategoryChannelsModelProtocol) {
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
    
    func showChannel(channel: Channel) {
//        self.delegate?.showChannel(channel: channel)
    }
    
    func update(index: Int, vm: SmallChannelViewModel) {
        self.channels[index] = vm
        self.delegate?.reloadChannels()
    }
}
