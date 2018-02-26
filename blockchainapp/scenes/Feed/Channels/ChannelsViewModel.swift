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
//    func updateSubscription()
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
    
//    func followUpdate(isSubscribed: Bool) {
//        self.isSubscribed = isSubscribed
//        self.delegate?.updateSubscription()
//    }
}
