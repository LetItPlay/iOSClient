//
//  UserPlaylistBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class UserPlaylistBuilder: Builder
{
    static func build(params: [String : Any]?) -> UIViewController? {
        let model = UserPlaylistModel()
        let vm = UserPlaylistViewModel(model: model)
        let emitter = UserPlaylistEmitter(model: model)
        let vc = UserPlaylistViewController(vm: vm, emitter: emitter)
        
        return vc
    }
}
