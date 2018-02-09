//
//  ProfileBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ProfileBuilder: Builder {
    static func build() -> UIViewController {
        let vc = ProfileViewController()
        var model = ProfileModel()
        let vm = ProfileViewModel()
        let emitter = ProfileEmitter.init(model: model)
        
        model.delegate = vm
        vm.delegate = vc.profileView
        vc.profileView.emitter = emitter
        emitter.model = model
        
        model = ProfileModel.init()
        
        return vc
    }
}
