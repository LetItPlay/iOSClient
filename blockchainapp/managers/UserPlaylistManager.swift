//
//  UserPlaylistManager.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol UserPlaylistDelegate: class {
    func update(tracks: [Track])
}

class UserPlaylistManager {
    static let shared: UserPlaylistManager = UserPlaylistManager()

    weak var delegate: UserPlaylistDelegate?
    var tracks: [Track] = []
        
    func add(track: Track, toBegining: Bool)
    {
        if let index = tracks.index(where: {$0.id == track.id}) {
            tracks.remove(at: index)
        }
        if toBegining {
            self.tracks.insert(track, at: 0)
        }
        else {
            self.tracks.append(track)
        }

        self.delegate?.update(tracks: tracks)
    }

    func remove(index: Int) {
        self.tracks.remove(at: index)
    }
    
    func clearPlaylist() {
        self.tracks.removeAll()
    }
}
