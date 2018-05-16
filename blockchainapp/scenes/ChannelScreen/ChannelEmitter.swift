//
//  ChannelVCEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ChannelEvent {
    case trackSelected(index: Int)
    case followPressed
    case showSearch
    case showOthers(index: Int)
    case shareChannel
    case tagSelected(String)
}

protocol ChannelEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: ChannelEvent)
}

class ChannelEmitter: Emitter, ChannelEmitterProtocol {
    
    weak var model: ChannelEvenHandler?
    
    convenience init(model: ChannelEvenHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: ChannelEvent) {
        switch event {
        case .followPressed:
            self.model?.followPressed()
        case .trackSelected(let index):
            self.model?.trackSelected(index: index)
        case .showSearch:
            self.model?.showSearch(text: nil)
        case .showOthers(let index):
            self.model?.showOthers(index: index)
        case .shareChannel:
            self.model?.showOthers()
        case .tagSelected(let tag):
            self.model?.selected(tag: tag)
        }
    }
}

