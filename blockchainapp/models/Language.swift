//
//  Language.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 07.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//


class Language {
    var identifier: String = "en"
    var name: String = "English"
    var currentLanguage: String = "Language: English"
    var switchTo: String = "Switch to English 🇬🇧"
    
    init(identifier: String, name: String, currentLanguage: String, switchTo: String) {
        self.identifier = identifier
        self.name = name
        self.currentLanguage = currentLanguage
        self.switchTo = switchTo
    }
}
