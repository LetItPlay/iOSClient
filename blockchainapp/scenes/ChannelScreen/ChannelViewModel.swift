//
//  ChannelVCViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelVMProtocol {
    var channel: FullChannelViewModel? {get}
    var isSubscribed: Bool {get set}
    var tracks: [TrackViewModel] {get}
    
    weak var delegate: ChannelVMDelegate? {get set}
}

protocol ChannelVMDelegate: class {
    func reloadTracks()
    func make(updates: [CollectionUpdate: [Int]])
    func updateSubscription()
}

class ChannelViewModel: ChannelVMProtocol, ChannelModelDelegate {

    var channel: FullChannelViewModel?
    var isSubscribed: Bool = false
    var tracks: [TrackViewModel] = []
    
    weak var delegate: ChannelVMDelegate?
    var model: ChannelModelProtocol!
    
    init(model: ChannelModelProtocol)
    {
        self.model = model
        self.model.delegate = self
    }
    
    func followUpdate(isSubscribed: Bool) {
        self.isSubscribed = isSubscribed
        self.delegate?.updateSubscription()
    }
    
    func reload(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.reloadTracks()
    }
    
    func trackUpdate(index: Int, vm: TrackViewModel) {
        var vm = self.tracks[index]
        vm.update(vm: vm)
        self.tracks[index] = vm
        self.delegate?.make(updates: [.update: [index]])
    }
    
    func getChannel(channel: FullChannelViewModel) {
        self.channel = channel
    }
}

