//
//  ProfileEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ProfileEmitterProtocol {
    func state(_ state: LifeCycleEvent)
    func set(name: String)
    func set(image: Data)
    func setLanguage()
}

class ProfileEmitter: ProfileEmitterProtocol {
    
    var model: ProfileModelProtocol!
    
    init(model: ProfileModelProtocol)
    {
        self.model = model
    }
    
    func set(name: String) {
        self.model.change(name: name)
    }
    
    func set(image: Data) {
        self.model.change(image: image)
    }
    
    func setLanguage() {
        self.model.changeLanguage()
    }
    
    func state(_ state: LifeCycleEvent) {
        switch state {
        case .initialize:
            self.model.getData()
        default:
            break
        }
    }
}
