//
//  ProfileEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ProfileEvent {
    case setName(String)
    case setImage(Data)
    case set(language: String)
    case authButtonPressed
}

protocol ProfileEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: ProfileEvent)
}

class ProfileEmitter: Emitter, ProfileEmitterProtocol {
    
    var model: ProfileModelProtocol!
    
    convenience init(model: ProfileModelProtocol)
    {
        self.init(handler: model)
        self.model = model
    }
	
    func send(event: ProfileEvent) {
        switch event {
        case .setImage(let image):
            self.model.change(image: image)
        case .setName(let name):
            self.model.change(name: name)
        case .set(let language):
            self.model.change(language: language)
        case .authButtonPressed:
            self.model.auth()
        }
    }
}
