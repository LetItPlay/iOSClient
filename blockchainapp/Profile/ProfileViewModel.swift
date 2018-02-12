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
    func make(updates: [ProfileUpdate])
}

class ProfileViewModel: ProfileModelDelegate {
    
    var name: String = ""
    var imageData: Data! = Data()
    var languageString: String = ""
    var language: Language = .none
    
    let languages = ["Switch to English 🇬🇧", "Поменять на Русский 🇷🇺"]
    
    weak var delegate: ProfileVMDelegate?
    
    func reload(name: String = "name", image: Data, language: Language = .en)
    {
        self.name = name
        self.imageData = image
        self.language = language
        self.getLanguage(lang: language)
        
        self.delegate?.make(updates: [.name, .image, .language])
    }
    
    func getLanguage(lang: Language)
    {
        switch lang {
        case .ru:
            self.languageString = languages[0]
        case .en:
            self.languageString = languages[1]
        default:
            self.languageString = ""
        }
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
    
    func update(language: Language)
    {
        self.getLanguage(lang: language)
        self.delegate?.make(updates: [.language])
    }
}
