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
    func updateTracks()
}

class LikesViewModel: LikesModelDelegate {    
    
    var tracks: [TrackViewModel] = []
    var currentPlayingIndex: Int = -1
    weak var delegate: LikesVMDelegate?
    var length: String = ""
    
    func reload(tracks: [TrackViewModel], length: String) {
        self.tracks = tracks
        self.length = length
        self.delegate?.reload()
    }
    
    func updateTrackAt(index: Int) {
        if index != -1
        {
            if currentPlayingIndex != -1
            {
                self.tracks[currentPlayingIndex].isPlaying = false
            }
            self.tracks[index].isPlaying = true
        }
        else
        {
            if currentPlayingIndex != -1
            {
                self.tracks[currentPlayingIndex].isPlaying = false
            }
        }
        
        self.currentPlayingIndex = index
        self.delegate?.updateTracks()
    }
}
