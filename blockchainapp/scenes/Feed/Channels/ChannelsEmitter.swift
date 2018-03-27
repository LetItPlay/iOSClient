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
    case subscribe(index: Int)
	case showAllChannels
    case showSearch
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
        
    func send(event: ChannelsEvent) {
        switch event {
        case .refreshData:
            self.model?.refreshChannels()
        case .showChannel(let index):
            self.model?.showChannel(index: index)
        case .subscribe(let index):
            self.model?.subscribeAt(index: index)
		case .showAllChannels:
			self.model?.showAllChannels()
        case .showSearch:
            self.model?.showSearch()
        }
    }
}
