//
//  ChannelsModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol ChannelsModelProtocol {
    func getData()
}

protocol ChannelsModelDelegate: class {
    func reload()
}

class ChannelsModel: ChannelsModelProtocol {
    
    weak var delegate: ChannelsModelDelegate?
    
    func getData() {
        
        delegate?.reload()
    }
}
