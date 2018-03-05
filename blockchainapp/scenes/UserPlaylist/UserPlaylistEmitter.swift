//
//  PlaylistEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum PlaylistEvent
{
    case trackSelected(index: Int)
    case clearPlaylist
}

protocol UserPlaylistEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: PlaylistEvent)
}

class UserPlaylistEmitter: Emitter, UserPlaylistEmitterProtocol
{
    weak var model: UserPlaylistEventHandler?
    
    convenience init(model: UserPlaylistEventHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: PlaylistEvent) {
        switch event {
        case .trackSelected(let index):
            self.model?.trackSelected(index: index)
        case .clearPlaylist:
            self.model?.clearPlaylist()
        }
    }
}
