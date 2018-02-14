//
//  ChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

class ChannelViewModel: SmallChannelViewModel {
    var name: String = ""
    var subscriptionCount: String = ""
    var tracksCount: String = ""
    var tags: List<Tag> = List<Tag>()
    
    override init(channel: Station) {
        super.init(channel: channel)
        
        self.name = channel.name
        self.subscriptionCount = Int64(channel.subscriptionCount).formatAmount()
        self.tracksCount = channel.tracksCount().formatAmount()
        self.tags = channel.tags
    }
}
