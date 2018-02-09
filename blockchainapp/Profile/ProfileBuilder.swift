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
        let model = ProfileModel()
        let vm = ProfileViewModel()
        let emitter = ProfileEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        let view = ProfileTopView.init(emitter: emitter, viewModel: vm)
        let vc = ProfileViewController.init(view: view)
        
        return vc
    }
}
