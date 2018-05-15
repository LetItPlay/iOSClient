//
//  PlaylistsViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol PlaylistsVMProtocol {
    var delegate: PlaylistsVMDelegate? {get set}
    var playlists: [PlaylistViewModel] {get set}
}

protocol PlaylistsVMDelegate: class {
    func update()
}

class PlaylistsViewModel: PlaylistsVMProtocol, PlaylistsModelDelegate {
    
    var playlists: [PlaylistViewModel] = []

    weak var delegate: PlaylistsVMDelegate?
    var model: PlaylistsModelProtocol!
    
    init(model: PlaylistsModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func update(playlists: [PlaylistViewModel]) {
        self.playlists = playlists
        self.delegate?.update()
    }
}
