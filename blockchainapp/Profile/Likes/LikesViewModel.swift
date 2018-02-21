//
//  LikesViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol LikesVMDelegate: class {
    func reload()
}

class LikesViewModel: LikesModelDelegate {    
    
    var tracks: [TrackViewModel] = []
    var currentPlayingIndex: Int? = nil
    weak var delegate: LikesVMDelegate?
    var length: String = ""
    
    func reload(tracks: [TrackViewModel], length: String) {
        self.tracks = tracks
        self.length = length
        self.delegate?.reload()
    }
}
