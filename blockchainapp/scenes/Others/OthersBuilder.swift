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
        let track = params!["track"]
        var trackID: Int! = -1
        if let id = params!["trackID"] {
            trackID = id as! Int
        }
        
        let model = OthersModel(track: track as! ShareInfo, trackID: trackID)
        let viewModel = OthersViewModel(model: model)
        let emitter = OthersEmitter(model: model)
        
        let viewContoller = OthersAlertController(viewModel: viewModel, emitter: emitter, viewController: viewController)
        return viewContoller
    }
}
