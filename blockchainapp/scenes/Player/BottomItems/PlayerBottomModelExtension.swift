//
//  PlayerBottomModelExtension.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/04/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

extension PlayerModel: MainPlayerBottomIconsEventHandler {
    func likeButtonTouched() {
        if playingIndex > -1 && playingIndex < self.tracks.count {
            ServerUpdateManager.shared.make(track: self.tracks[playingIndex], action: .like)
        }
    }
    
    func showOthersButtonTouched() {
        if let current = self.currentTrack {
            self.playerDelegate?.showMoreDialog(track: current.sharedInfo())
        }
    }
    
    func speedButtonTouched() {
        self.playerDelegate?.showSpeedSettings()
    }
}

extension PlayerModel: TrackUpdateProtocol {
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            self.tracks[index] = track
            let isPlaying = self.playingNow == track.id && self.player.status == .playing
            let trackVM = TrackViewModel.init(track: track, isPlaying: isPlaying)
            self.playlistDelegate?.update(dict: [index: trackVM])
            if isPlaying {
                self.playerDelegate?.update(track: trackVM)
            }
        }
    }
}
