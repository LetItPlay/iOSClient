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
    
    func reload(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.reload()
    }
}
