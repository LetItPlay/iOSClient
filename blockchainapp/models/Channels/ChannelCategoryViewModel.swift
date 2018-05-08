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
    
    init(category: ChannelCategory) {
        self.name = category.name
        let channels = category.channels
        self.channels = channels.map({CategoryChannelViewModel(channel: $0)})
    }
}
