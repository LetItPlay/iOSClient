//
//  ChannelVCModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChannelVCModelProtocol {
    func getTracks()
}

protocol ChannelVCModelDelegate {
    func reload(tracks: [TrackViewModel])
}

class ChannelVCModel: ChannelVCModelProtocol {
    
    var delegate: ChannelVCModelDelegate?
    
    var tracks = [Track]()
    
    func getTracks() {
        
    }
}
