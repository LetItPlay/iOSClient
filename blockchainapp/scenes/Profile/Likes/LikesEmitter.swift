//
//  LikesEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum LikesTrackEvent {
    case trackSelected(index: Int)
    case showOthers(index: Int)
    case hidePlayer
}

protocol LikesEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: LikesTrackEvent)
}

class LikesEmitter: Emitter, LikesEmitterProtocol {
    
    var model: LikesEventHandler?
    
    convenience init(model: LikesEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
	
    func state(_ state: LifeCycleEvent) {
        switch state {
        case .initialize:
            break
		default: break
		}
	}
	
    func send(event: LikesTrackEvent) {
        switch event {
        case .trackSelected(let index):
            self.model?.trackSelected(index: index)
        case .showOthers(let index):
            self.model?.showOthers(index: index)
        case .hidePlayer:
            self.model?.hidePlayer()
        }
    }
}
