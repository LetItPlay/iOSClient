//
//  LikesEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol LikesEmitterProtocol {
    func state(_ state: ViewState)
    func reloadTracks()
}

class LikesEmitter: LikesEmitterProtocol {
    
    var model: LikesModelProtocol!
    
    init(model: LikesModelProtocol) {
        self.model = model
    }
    
    func reloadTracks() {
        self.model.getTracks()
    }
    
    func state(_ state: ViewState) {
        switch state {
        case .initialize:
            self.model.getTracks()
        default:
            break
        }
    }
}
