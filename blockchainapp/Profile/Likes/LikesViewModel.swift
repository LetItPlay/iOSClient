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
    func make(updates: [CollectionUpdate: [Int]])
}

class LikesViewModel: LikesModelDelegate {    
    
    var tracks: [TrackViewModel] = []
    weak var delegate: LikesVMDelegate?
    var length: String = ""
    
    func reload(tracks: [TrackViewModel], length: String) {
        self.tracks = tracks
        self.length = length
        self.delegate?.reload()
    }
    
    func trackUpdate(index: Int, vm: TrackViewModel) {
        var vm = self.tracks[index]
        vm.update(vm: vm)
        self.tracks[index] = vm
        self.delegate?.make(updates: [.update: [index]])
    }
}
