//
//  LikesViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol LikesVMDelegate: class {
    func updateTracks()
}

class LikesViewModel: LikesModelDelegate {
    
    var tracks: [Track] = []
    weak var delegate: LikesVMDelegate?
    
    func reloadTracks(newTracks: [Track]) {
        self.tracks = newTracks
        self.delegate?.updateTracks()
    }
}
