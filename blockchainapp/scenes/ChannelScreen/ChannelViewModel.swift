//
//  ChannelVCViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelVMProtocol: TrackHandlingViewModelProtocol {
    var channel: FullChannelViewModel? {get}
    var isSubscribed: Bool {get set}
    
    var channelDelegate: ChannelVMDelegate? {get set}
}

protocol ChannelVMDelegate: class {
    func updateSubscription()
}

class ChannelViewModel: TrackHandlingViewModel, ChannelVMProtocol, ChannelModelDelegate {

    var channel: FullChannelViewModel?
    var isSubscribed: Bool = false
    
    weak var channelDelegate: ChannelVMDelegate?
    
    func getChannel(channel: FullChannelViewModel) {
        self.channel = channel
        self.isSubscribed = channel.isSubscribed
        self.channelDelegate?.updateSubscription()
    }
    
    func showSearch(text: String?) {
        MainRouter.shared.show(screen: "search", params: ["text" : text as Any], present: false)
    }
    
    func showOthers(shareInfo: ShareInfo) {
        MainRouter.shared.showOthers(shareInfo: shareInfo)
    }
}

