//
//  ProfileViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

struct ProfileViewModel {
    var name: String = ""
    var imageURL: URL? = nil
    var language: String = ""
    
    init(name: String = "name", image: String, language: String = "en")
    {
        self.name = name
        self.imageURL = URL.init(string: image)
        self.language = language
    }
}
