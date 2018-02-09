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
    func change(language: Language)
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
    
    func change(language: Language) {
        UserSettings.language = language
        self.delegate?.update(language: UserSettings.language)
    }
}
