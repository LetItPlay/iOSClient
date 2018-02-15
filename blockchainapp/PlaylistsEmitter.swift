//
//  PlaylistsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol PlaylistsEmitterProtocol: LifeCycleHandlerProtocol {
    func formatPlaylists(index: Int)
}

class PlaylistsEmitter: Emitter, PlaylistsEmitterProtocol {
    
    weak var model: PlaylistsEventHandler?
    
    convenience init(model: PlaylistsEventHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func formatPlaylists(index: Int) {
        self.model?.formatPlaylists(index: index)
    }
}
