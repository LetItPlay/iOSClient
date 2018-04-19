//
//  OthersViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

protocol OthersVMProtocol {
    weak var delegate: OthersVMDelegate? {get set}
    
//    var trackShareInfo: TrackShareInfo? {get set}
}

protocol OthersVMDelegate: class {
    func addTrack()
}

class OthersViewModel: OthersVMProtocol, OthersModelDelegate {
    var delegate: OthersVMDelegate?
    var model: OthersModelProtocol!
    
//    var trackShareInfo: TrackShareInfo?
    
    init(model: OthersModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func share(trackShareInfo: ShareInfo, viewController: UIViewController) {
        MainRouter.shared.share(data: trackShareInfo, viewController: viewController)
    }
}
