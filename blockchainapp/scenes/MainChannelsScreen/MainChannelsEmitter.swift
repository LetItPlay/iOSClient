//
//  MainChannelsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum MainChannelsEvent {
    case showChannel(index: IndexPath)
    case showAllChannels(index: Int)
    case refresh
}

protocol MainChannelsEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: MainChannelsEvent)
}

class MainChannelsEmitter: Emitter, MainChannelsEmitterProtocol {
    weak var model: MainChannelsEventHandler?
    
    convenience init(model: MainChannelsEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: MainChannelsEvent) {
        switch event {
        case .showAllChannels(let index):
            self.model?.showAllChannelsFor(section: index)
        case .showChannel(let index):
            self.model?.showChannel(section: index.section, index: index.row)
        case .refresh:
            self.model?.refresh()
        }
    }
}
