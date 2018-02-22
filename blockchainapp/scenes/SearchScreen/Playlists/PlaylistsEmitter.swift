//
//  PlaylistsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum PlaylistsEvent {
    case formatPlaylists(index: Int)
    case refresh
}

protocol PlaylistsEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: PlaylistsEvent)
}

class PlaylistsEmitter: Emitter, PlaylistsEmitterProtocol {
    
    weak var model: PlaylistsEventHandler?
    
    convenience init(model: PlaylistsEventHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: PlaylistsEvent) {
        switch event {
        case .formatPlaylists(let index):
            self.model?.formatPlaylists(index: index)
        case .refresh:
            self.model?.refresh()
        }
    }
}
