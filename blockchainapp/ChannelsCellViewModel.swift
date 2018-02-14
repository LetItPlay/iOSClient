//
//  ChannelsCellViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

class ChannelsCellViewModel {
    
    var channelName: String = ""
    var subscriptionCount: String = ""
    var tracksCount: String = ""
    var tags: List<Tag> = List<Tag>()
    var imageUrl: URL? = nil
    
    init(channel: ChannelViewModel)
    {
        self.channelName = channel.name
        self.subscriptionCount = channel.subscriptionCount
        self.tracksCount = channel.tracksCount
        self.tags = channel.tags
        self.imageUrl = channel.imageURL
    }
}
