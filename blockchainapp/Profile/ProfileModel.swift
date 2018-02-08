//
//  ProfileModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileModelDelegate: class {
    func reload(name: String, image: Data, language: String)
    func update(image: Data)
    func update(name: String)
    func update(language: String)
}

class ProfileModel {
    
    weak var delegate: ProfileModelDelegate?
    
    init()
    {
        delegate?.reload(name: UserSettings.name, image: UserSettings.image, language: UserSettings.language.rawValue)
    }
}
