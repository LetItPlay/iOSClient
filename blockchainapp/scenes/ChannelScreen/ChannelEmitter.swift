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
    case showSearch
    case shareChannel
    case tagSelected(String)
}

protocol ChannelEmitterProtocol: TrackHandlingEmitterProtocol {
    func send(event: ChannelEvent)
}

class ChannelEmitter: TrackHandlingEmitter, ChannelEmitterProtocol {
    
    weak var channelModel: ChannelEvenHandler?
    
    func send(event: ChannelEvent) {
        switch event {
        case .followPressed:
            self.channelModel?.followPressed()
        case .showSearch:
            self.channelModel?.showSearch(text: nil)
        case .shareChannel:
            self.channelModel?.showOthers()
        case .tagSelected(let tag):
            self.channelModel?.selected(tag: tag)
        }
    }
}

