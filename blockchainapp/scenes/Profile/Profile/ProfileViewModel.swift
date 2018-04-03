//
//  ProfileViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum ProfileUpdate {
    case image, name, language, authorization
}

protocol ProfileVMDelegate: class {
    func make(updates: [ProfileUpdate])
}

class ProfileViewModel: ProfileModelDelegate {
    
    var name: String = ""
    var imageData: Data! = Data()
    var languageString: String = ""
    var textForAuthButton: String = ""
    
    var currentLanguage = ""
    
    var isAuthorized: Bool = false
    
    weak var delegate: ProfileVMDelegate?
    
    func reload(name: String, image: Data, language: Language = .en, isLogged: Bool)
    {
        self.name = name
        self.imageData = image
        self.getLanguage(lang: language)
        
        self.isAuthorized = isLogged
        self.textForAuthButton = isLogged ? "Log out".localized : "Authorization".localized
        
        self.delegate?.make(updates: [.name, .image, .language, .authorization])
    }
    
    func getLanguage(lang: Language)
    {
        switch lang {
        case .ru:
            self.currentLanguage = "Язык: Русский"
        case .en:
            self.currentLanguage = "Language: English"
        case .fr:
            self.currentLanguage = "Langue: Français"
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
