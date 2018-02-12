//
//  ChannelsModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsModelProtocol {
    func getChannels()
}

protocol ChannelsModelDelegate: class {
    func reloadChannels(newChannels: [Station])
}

class ChannelsModel: ChannelsModelProtocol, ChannelsViewProtocol {

    weak var delegate: ChannelsModelDelegate?
    var presenter: ChannelsPresenter!
    
    func getChannels() {
        presenter = ChannelsPresenter(view: self)
        presenter.getData { [weak self] (channels) in
            self?.display(channels: channels)
        }
    }
    
    func display(channels: [Station]) {
        self.delegate?.reloadChannels(newChannels: channels)
    }
    
    func select(rows: [Int]) {
        
    }
}
