//
//  LikesEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum LikeTrackAction {
    case selected
}

protocol LikesEmitterProtocol: LifeCycleHandlerProtocol {
    func make(action: LikeTrackAction, index: Int)
}

class LikesEmitter: Emitter, LikesEmitterProtocol {
    
    var model: LikesModelProtocol!
    
    convenience init(model: LikesModelProtocol) {
        self.init(handler: model)
        self.model = model
    }
	
    func state(_ state: LifeCycleEvent) {
        switch state {
        case .initialize:
            self.model.getTracks()
		default: break
		}
	}
	func make(action: LikeTrackAction, index: Int) {
        switch action {
        case .selected:
            self.model.selectedTrack(index: index)
        default:
            break
        }
	}
}
