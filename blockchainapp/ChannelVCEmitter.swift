//
//  ChannelVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ChannelVCEvent {
    case followPressed
}

protocol ChannelVCEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: ChannelVCEvent)
}

class ChannelVCEmitter: Emitter, ChannelVCEmitterProtocol {
    
    weak var model: ChannelVCEvenHandler?
    
    convenience init(model: ChannelVCEvenHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: ChannelVCEvent) {
        switch event {
        case .followPressed:
            self.model?.followPressed()
        }
    }
}
