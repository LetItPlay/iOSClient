//
//  ChannelVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ChannelEvent {
    case followPressed
}

protocol ChannelEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: ChannelEvent)
}

class ChannelEmitter: Emitter, ChannelEmitterProtocol {
    
    weak var model: ChannelEvenHandler?
    
    convenience init(model: ChannelEvenHandler, station: Station)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
        self.model?.set(station: station)
    }
    
    func send(event: ChannelEvent) {
        switch event {
        case .followPressed:
            self.model?.followPressed()
//        case .station(let station):
//            self.model?.set(station: station)
        }
    }
}

