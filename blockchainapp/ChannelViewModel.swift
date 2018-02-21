//
//  ChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

struct ChannelViewModel {
    var name: String = ""
    var imageURL: URL? = nil
//    var sourceURL: URL? = nil // ?
    var subscriptionCount: String = ""
    var trackCount: String = "" // ? Int
    var language: String = ""
//    var tags: List<Tag> = List<Tag>()
    
    init(channel: Station)
    {
        self.name = channel.name
        self.imageURL = URL.init(string: channel.image)
        self.subscriptionCount = "\(channel.subscriptionCount)"
        self.trackCount = "\(channel.trackCount)"
        self.language = channel.lang
    }
}
