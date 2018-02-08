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

protocol ProfileVMProtocol {
    func set(name: String)
    func set(image: Data)
    func set(language: String)
}

protocol ProfileVMDelegate: class {
    func reload()
    func make(updates: [ProfileUpdate])
}

class ProfileViewModel: ProfileVMProtocol, ProfileModelDelegate {
    var name: String = ""
    var imageData: Data? = nil
    var language: String = ""
    
    weak var delegate: ProfileVMDelegate?
    private var model: ProfileModelProtocol!
    
    init(model: ProfileModelProtocol) {
        self.model = model
    }
    
    func reload(name: String = "name", image: Data, language: String = "en")
    {
        self.name = name
        self.imageData = image
        self.language = language
        self.delegate?.reload()
    }
    
    func update(image: Data)
    {
        self.imageData  = image
        self.delegate?.make(updates: [.image])
    }
    
    func update(name: String)
    {
        self.name = name
        self.delegate?.make(updates: [.name])
    }
    
    func update(language: String)
    {
        self.language = language
        self.delegate?.make(updates: [.language])
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
