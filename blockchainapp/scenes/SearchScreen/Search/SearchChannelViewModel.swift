//
//  SearchChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

class SearchChannelViewModel: SmallChannelViewModel {
    var name: String = ""
    var subscriptionCount: String = ""
    var tracksCount: String = ""
    
    override init(channel: Station1) {
        super.init(channel: channel)
        
        self.name = channel.name
        self.subscriptionCount = Int64(channel.subscriptionCount).formatAmount()
        self.tracksCount = Int64(channel.trackCount).formatAmount()
    }
}
