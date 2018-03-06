//
//  UserPlaylistManager.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class UserPlaylistManager
{
    static let shared: UserPlaylistManager = UserPlaylistManager()
    
    var tracks: [Track] = []
        
    func add(track: Track, toBegining: Bool)
    {
        if toBegining
        {
            self.tracks.insert(track, at: 0)
        }
        else
        {
            self.tracks.append(track)
        }
    }
    
    func clearPlaylist()
    {
        self.tracks.removeAll()
    }
}
