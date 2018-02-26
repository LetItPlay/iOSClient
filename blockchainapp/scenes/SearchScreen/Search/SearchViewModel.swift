//
//  SearchViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol SearchVMProtocol {
    weak var delegate: SearchVMDelegate? {get set}
    var tracks: [TrackViewModel] {get set}
    var channels: [SearchChannelViewModel] {get set}
    var currentPlayingIndex: Int {get set}
}

protocol SearchVMEmitterProtocol: class {
    func getTypeFor(section: Int) -> ViewModels
}

protocol SearchVMDelegate: class {
    func update(data: ViewModels)
}

class SearchViewModel: SearchVMProtocol, SearchModelDelegate, SearchVMEmitterProtocol {
    
    var delegate: SearchVMDelegate?
    var model: SearchModelProtocol!
    
    var tracks: [TrackViewModel] = []
    var channels: [SearchChannelViewModel] = []
    
    var currentPlayingIndex: Int = -1
    
    init(model: SearchModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func update(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.update(data: .tracks)
    }
    
    func update(channels: [SearchChannelViewModel]) {
        self.channels = channels
        self.delegate?.update(data: .channels)
    }
    
    // for emitter
    func getTypeFor(section: Int) -> ViewModels {
        switch section {
        case 0:
            return ViewModels.channels
        case 1:
            return ViewModels.tracks
        default:
            return ViewModels.channels
        }
    }
}
