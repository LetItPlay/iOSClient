//
//  ProfileBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ProfileBuilder: Builder {
    static func build(params: [String : Any]?) -> UIViewController? {
        
        // for profile view
        let model = ProfileModel()
        let vm = ProfileViewModel()
        let emitter = ProfileEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        // for like tracks
        let likeModel = LikesModel()
        let likeVM = LikesViewModel()
        likeModel.delegate = likeVM
        let likeEmitter = LikesEmitter.init(model: likeModel)
        likeEmitter.likesModel = likeModel
        
        let view = ProfileHeaderView.init(emitter: emitter, viewModel: vm)
        let vc = ProfileViewController.init(view: view, emitter: likeEmitter, viewModel: likeVM)
        
        return vc
    }
}
