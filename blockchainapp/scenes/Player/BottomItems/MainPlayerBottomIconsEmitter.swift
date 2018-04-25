//
//  MainPlayerBottomIconsEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

enum MainPlayerBottomIconsEvent {
    case likeButtonTouched, speedButtonTouched, showOthersButtonTouched
}

protocol MainPlayerBottomIconsEmitterProtocol {
    func send(event: MainPlayerBottomIconsEvent)
}

protocol MainPlayerBottomIconsEventHandler {
    func likeButtonTouched()
    func showOthersButtonTouched()
    func speedButtonTouched()
}

class MainPlayerBottomIconsEmitter: MainPlayerBottomIconsEmitterProtocol {
    
    var model: MainPlayerBottomIconsEventHandler?
    
    convenience init(model: MainPlayerBottomIconsEventHandler) {
//        self.init(handler: model as! ModelProtocol)
        self.init()
        self.model = model
    }
    
    func send(event: MainPlayerBottomIconsEvent) {
        switch event {
        case .likeButtonTouched:
            self.model?.likeButtonTouched()
        case .showOthersButtonTouched:
            self.model?.showOthersButtonTouched()
        case .speedButtonTouched:
            self.model?.speedButtonTouched()
        }
    }
}
