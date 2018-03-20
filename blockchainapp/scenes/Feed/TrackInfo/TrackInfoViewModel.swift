//
//  TrackInfoViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum TrackInfoResultUpdate {
    case track, channel
}

protocol TrackInfoVMDelegate: class {
    func update(data: TrackInfoResultUpdate)
}

class TrackInfoViewModel: TrackInfoModelDelegate {
    
    var track: TrackViewModel!
    var channel: SearchChannelViewModel!
    
    weak var delegate: TrackInfoVMDelegate?
    
    func reload(track: TrackViewModel) {
        self.track = track
        
        delegate?.update(data: .track)
    }
    
    func reload(channel: SearchChannelViewModel) {
        self.channel = channel
        
        delegate?.update(data: .channel)
    }
}
