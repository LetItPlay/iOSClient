//
//  TrackInfoEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum TrackInfoEvent {
    case updateTrack(id: Int)
    case trackLiked(index: Int)
}

protocol TrackInfoEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: TrackInfoEvent)
}

class TrackInfoEmitter: Emitter, TrackInfoEmitterProtocol {
    
    var model: TrackInfoEventHandler!
    
    convenience init(model: TrackInfoEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: TrackInfoEvent) {
        switch event {
        case .updateTrack(let id):
            self.model.updateTrack(id: id)
        case .trackLiked(let index):
            self.model.trackLiked(id: index)
        }
    }
}
