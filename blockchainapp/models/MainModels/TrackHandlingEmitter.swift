//
//  TrackHandlingEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 17.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum TrackEvent {
    case reload
    case trackSelected(index: Int)
    case trackLiked(index: Int)
    case trackShowed(index: Int)
    case showChannel(index: Int)
    case showOthers(index: Int)
    case addTrack(index: Int, toBeginning: Bool)
}

protocol TrackHandlingEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: TrackEvent)
}

class TrackHandlingEmitter: Emitter, TrackHandlingEmitterProtocol {
    weak var model: TrackEventHandler?
    
    convenience init(model: TrackEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: TrackEvent) {
        switch event {
        case .reload:
            self.model?.reload()
        case .trackLiked(let index):
            self.model?.trackLiked(index: index)
        case .trackShowed(let index):
            self.model?.trackShowed(index: index)
        case .showChannel(let index):
            self.model?.showChannel(index: index)
        case .showOthers(let index):
            self.model?.showOthers(index: index)
        case .addTrack(let index, let toBeginning):
            self.model?.addTrack(index: index, toBegining: toBeginning)
        case .trackSelected(let index):
            self.model?.trackSelected(index: index)
        }
    }
}
