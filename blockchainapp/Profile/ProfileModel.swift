//
//  ProfileModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileModelProtocol {
    func change(image: Data)
    func change(name: String)
    func change(language: String)
}

protocol ProfileModelDelegate: class {
    func reload(name: String, image: Data, language: String)
    func update(image: Data)
    func update(name: String)
    func update(language: String)
}

class ProfileModel: ProfileModelProtocol {
    
    weak var delegate: ProfileModelDelegate?
    
    init()
    {
        delegate?.reload(name: UserSettings.name, image: UserSettings.image, language: UserSettings.language.rawValue)
    }
    
    func change(image: Data) {
        UserSettings.image = image
    }
    
    func change(name: String) {
        UserSettings.name = name
    }
    
    func change(language: String) {
        switch language {
        case "ru":
            UserSettings.language = .ru
        case "en":
            UserSettings.language = .en
        default:
            UserSettings.language = .none
        }
    }
}
