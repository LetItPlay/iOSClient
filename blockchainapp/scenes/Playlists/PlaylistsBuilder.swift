//
//  PlaylistsBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 28.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class PlaylistsBuilder: Builder {
    static func build(params: [String : Any]?) -> UIViewController? {
        let model = PlaylistsModel()
        let vm = PlaylistsViewModel(model: model)
        let emitter = PlaylistsEmitter(model: model)
        
        return PlaylistsViewController(playlistViewModel: vm, playlistEmitter: emitter)
    }
}
