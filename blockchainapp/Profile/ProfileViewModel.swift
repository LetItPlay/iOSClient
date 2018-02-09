//
//  ProfileViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ProfileUpdate {
    case image, name, language
}

protocol ProfileVMDelegate: class {
    func reload(name: String, imageData: Data, language: String)
    func make(updates: ProfileUpdate, data: Any)
}

class ProfileViewModel: ProfileModelDelegate {
    var name: String = ""
    var imageData: Data? = nil
    var language: String = ""
    
    weak var delegate: ProfileVMDelegate?
    
    func reload(name: String = "name", image: Data, language: String = "en")
    {
        self.name = name
        self.imageData = image
        self.language = language
        self.delegate?.reload(name: name, imageData: image, language: language)
    }
    
    func update(image: Data)
    {
        self.imageData  = image
        self.delegate?.make(updates: .image, data: image)
    }
    
    func update(name: String)
    {
        self.name = name
        self.delegate?.make(updates: .name, data: name)
    }
    
    func update(language: String)
    {
        self.language = language
        self.delegate?.make(updates: .language, data: language)
    }
}
