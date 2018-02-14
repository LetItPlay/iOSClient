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
        
        // for profile view
        let model = ProfileModel()
        let vm = ProfileViewModel()
        let emitter = ProfileEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        // for like tracks
        let likeModel = LikesModel()
        let likeVM = LikesViewModel()
        let likeEmitter = LikesEmitter.init(model: likeModel)
        
        likeModel.delegate = likeVM
        likeEmitter.model = likeModel
        
        let view = ProfileTopView.init(emitter: emitter, viewModel: vm)
        let vc = ProfileViewController.init(view: view, emitter: likeEmitter, viewModel: likeVM)
        
        return vc
    }
}
