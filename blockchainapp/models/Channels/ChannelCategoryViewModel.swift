//
//  ChannelCategoryViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 03.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class ChannelCategoryViewModel {
    var name: String = ""
    var channels: [CategoryChannelViewModel]!
    var hideSeeAllButton: Bool = true
    
    init(name: String, channels: [CategoryChannelViewModel]) {
        self.name = name
        self.channels = channels.count > 5 ? Array(channels[0...4]) : channels
        self.hideSeeAllButton = channels.count > 5 ? false : true
    }
    
    init(category: ChannelCategory) {
        self.name = category.name
        let channels = category.channels.count > 5 ? Array(category.channels[0...4]) : category.channels
        self.channels = channels.map({CategoryChannelViewModel(channel: $0)})
        self.hideSeeAllButton = category.channels.count > 5 ? false : true
    }
}
