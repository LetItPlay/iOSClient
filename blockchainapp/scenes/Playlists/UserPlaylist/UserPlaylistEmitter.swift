//
//  PlaylistEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

enum UserPlaylistEvent
{
    case trackSelected(index: Int)
    case clearPlaylist
    case trackDelete(index: Int)
    case showOthers(index: Int, viewController: UIViewController)
}

protocol UserPlaylistEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: UserPlaylistEvent)
}

class UserPlaylistEmitter: Emitter, UserPlaylistEmitterProtocol
{
    weak var model: UserPlaylistEventHandler?
    
    convenience init(model: UserPlaylistEventHandler)
    {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: UserPlaylistEvent) {
        switch event {
        case .trackSelected(let index):
            self.model?.trackSelected(index: index)
        case .clearPlaylist:
            self.model?.clearPlaylist()
        case .trackDelete(let index):
            self.model?.trackDelete(index: index)
        case .showOthers(let index, let viewController):
            self.model?.showOthers(index: index, viewController: viewController)
        }
    }
}
