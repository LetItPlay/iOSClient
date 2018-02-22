//
//  ProfileModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ProfileModelProtocol: class, ModelProtocol {
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
    
    init()
    {
        InAppUpdateManager.shared.subscribe(self)
    }
    
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
        ServerUpdateManager.shared.updateLanguage()
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.getData()
        default:
            break
        }
    }
}

extension ProfileModel: SettingsUpdateProtocol {
    func settingsUpdated() {
        self.delegate?.update(language: UserSettings.language)
    }
}
