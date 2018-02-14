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
}

class ChannelVCViewModel: ChannelVCModelDelegate {
    
    var channel: FullChannelViewModel?
    var tracks: [TrackViewModel] = []
    
    weak var delegate: ChannelVCVMDelegate?
    
    func reload(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.reloadTracks()
    }
}
