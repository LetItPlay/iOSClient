//
//  LikesEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol LikesEmitterProtocol: LifeCycleHandlerProtocol {
    func make(action: TrackAction, index: Int)
}

class LikesEmitter: Emitter, LikesEmitterProtocol {
    
    var model: LikesModelProtocol!
    
    convenience init(model: LikesModelProtocol) {
        self.init(handler: model)
        self.model = model
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
