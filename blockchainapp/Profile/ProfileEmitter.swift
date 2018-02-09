//
//  ProfileEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ProfileEmitterProtocol {
    func set(name: String)
    func set(image: Data)
    func set(language: String)
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
    
    func set(language: String) {
        self.model.change(language: language)
    }
}
