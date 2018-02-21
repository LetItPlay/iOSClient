//
//  ChannelsEmitter.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsEmitterProtocol: LifeCycleHandlerProtocol {
    func showChannel(index: Int)
}

class ChannelsEmitter: Emitter, ChannelsEmitterProtocol {
    weak var model: ChannelsEventHandler?
    
    convenience init(model: ChannelsEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func state(_ state: LifeCycleEvent) {
        switch state {
//        case .initialize:
//            self.model.getChannels()
        default:
            break
        }
	}
    func showChannel(index: Int) {
        self.model?.showChannel(index: index)
    }
}
