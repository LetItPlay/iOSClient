//
//  ProfileModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ProfileModelProtocol {
    func change(image: Data)
    func change(name: String)
    func changeLanguage()
    func getData()
}

protocol ProfileModelDelegate: class {
    func reload(name: String, image: Data, language: Language)
    func update(image: Data)
    func update(name: String)
    func update(language: Language)
}

class ProfileModel: ProfileModelProtocol {
    
    weak var delegate: ProfileModelDelegate?
    
    func getData() {
        delegate?.reload(name: UserSettings.name, image: UserSettings.image, language: UserSettings.language)
    }
    
    func change(image: Data) {
        UserSettings.image = image
        self.delegate?.update(image: UserSettings.image)
    }
    
    func change(name: String) {
        UserSettings.name = name
        self.delegate?.update(name: UserSettings.name)
    }
    
    func changeLanguage() {
        switch UserSettings.language {
        case .ru:
            UserSettings.language = .en
        case .en:
            UserSettings.language = .ru
        default:
            UserSettings.language = .none
        }
        
        self.delegate?.update(language: UserSettings.language)
    }
}
