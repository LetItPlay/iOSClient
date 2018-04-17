//
//  OthersViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

protocol OthersVMProtocol {
    var delegate: OthersVMDelegate? {get set}
    
    var reportObjects: [(title: String, event: OthersEvent)] {get set}
}

protocol OthersVMDelegate: class {
}

class OthersViewModel: OthersVMProtocol, OthersModelDelegate {
    weak var delegate: OthersVMDelegate?
    var model: OthersModelProtocol!
    
    var reportObjects: [(title: String, event: OthersEvent)] = [(title: "Спам", event: OthersEvent.report(.spam)),
                                                                (title: "Контент для взрослых", event: OthersEvent.report(.adultContent)),
                                                                (title: "Жестокий контент", event: OthersEvent.report(.cruelContent))]
    
    init(model: OthersModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func share(trackShareInfo: ShareInfo, viewController: UIViewController) {
        MainRouter.shared.share(data: trackShareInfo, viewController: viewController)
    }
}
