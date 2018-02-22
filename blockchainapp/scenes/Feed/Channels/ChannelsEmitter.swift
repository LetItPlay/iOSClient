//
//  ChannelsEmitter.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ChannelsEvent {
    case showChannel(index: Int)
    case refreshData
    case followPressed
}

protocol ChannelsEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: ChannelsEvent)
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
    
    func send(event: ChannelsEvent) {
        switch event {
        case .refreshData:
            self.model?.refreshChannels()
        case .showChannel(let index):
            break
//            self.model?.showChannel(index: index)
        case .followPressed:
            self.model?.followPressed()
        }
    }
}
