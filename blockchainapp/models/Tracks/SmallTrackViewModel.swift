//
//  SmallTrackViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 13.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class SmallTrackViewModel {
    
    var iconUrl: URL? = nil
    var trackName: String = ""
    var channelName: String = ""
    var time: String = ""
    var listens: String = ""
    var length: String = ""
    
    init(track: TrackViewModel)
    {
        self.iconUrl = track.imageURL
        self.trackName = track.name
        
        self.channelName = track.author
        self.time = track.dateString
        self.listens = track.listensCount
        self.length = track.length
    }
    
}
