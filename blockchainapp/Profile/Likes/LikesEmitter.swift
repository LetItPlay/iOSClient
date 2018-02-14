//
//  LikesEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol LikesEmitterProtocol {
    func reloadTracks()
    func make(action: TrackAction, index: Int)
}

class LikesEmitter: LikesEmitterProtocol {
    
    var model: LikesModelProtocol!
    
    init(model: LikesModelProtocol) {
        self.model = model
    }
    
    func reloadTracks() {
        self.model.getTracks()
    }
    
    func make(action: TrackAction, index: Int) {
        switch action {
        case .selected:
            self.model.selectedTrack(index: index)
        default:
            break
        }
    }
    
}
