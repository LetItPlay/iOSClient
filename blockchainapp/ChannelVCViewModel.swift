//
//  ChannelVCViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelVCVMDelegate: class {
    func reloadTracks()
    func updateSubscription()
}

class ChannelVCViewModel: ChannelVCModelDelegate {

    var channel: FullChannelViewModel?
    var isSubscribed: Bool = false
    var tracks: [TrackViewModel] = []
    
    weak var delegate: ChannelVCVMDelegate?
    
    func followUpdate(isSubscribed: Bool) {
        self.isSubscribed = isSubscribed
        self.delegate?.updateSubscription()
    }
    
    func reload(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.reloadTracks()
    }
    
    func update(index: Int, track: TrackViewModel) {
//        self.delegate?.make(updates: [.update: [index]])
    }
}
