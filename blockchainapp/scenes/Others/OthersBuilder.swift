//
//  OthersBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class OthersBuilder: Builder {
    static func build(params: [String : Any]?) -> UIViewController? {
        let viewController = params!["controller"] as! UIViewController
        let infoToShare = params!["shareInfo"]
        
        let model = OthersModel(infoToShare: infoToShare as! ShareInfo)
        let viewModel = OthersViewModel(model: model)
        let emitter = OthersEmitter(model: model)
        
        let viewContoller = OthersAlertController(viewModel: viewModel, emitter: emitter, viewController: viewController)
        return viewContoller
    }
}
