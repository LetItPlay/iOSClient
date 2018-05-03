//
//  MainChannelsViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol MainChannelsVMProtocol {
    var categories: [String : [CategoryChannelViewModel]] {get}
    
    var delegate: MainChannelsVMDelegate? {get set}
}

protocol MainChannelsVMDelegate: class {
    func reloadCategories()
}

class MainChannelsViewModel: MainChannelsVMProtocol, MainChannelsModelDelegate {
    
    var categories: [String : [CategoryChannelViewModel]] = [:]
    
    var delegate: MainChannelsVMDelegate?
    var model: MainChannelsModelProtocol!
    
    init(model: MainChannelsModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func reload(categories: [String : [CategoryChannelViewModel]]) {
        self.categories = categories
        self.delegate?.reloadCategories()
    }
    
    func showChannel(id: Int) {
        MainRouter.shared.show(screen: "channel", params: ["id": id], present: false)
    }
    
    func showAllChannelsFor(category: String) {
        // TODO: add categories
        MainRouter.shared.show(screen: "allChannels", params: [:], present: false)
    }
}
