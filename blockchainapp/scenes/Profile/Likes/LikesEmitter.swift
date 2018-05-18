//
//  LikesEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum LikesTrackEvent {
    case hidePlayer
}

protocol LikesEmitterProtocol: TrackHandlingEmitterProtocol {
    func send(event: LikesTrackEvent)
}

class LikesEmitter: TrackHandlingEmitter, LikesEmitterProtocol {
    
    var likesModel: LikesEventHandler?
	
    func send(event: LikesTrackEvent) {
        switch event {
        case .hidePlayer:
            self.likesModel?.hidePlayer()
        }
    }
}
