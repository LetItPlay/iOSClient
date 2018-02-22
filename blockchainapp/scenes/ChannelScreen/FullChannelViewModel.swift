//
//  FullChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class FullChannelViewModel: MediumChannelViewModel {
    var description: String = ""
    
    override init(channel: Station1) {
        super.init(channel: channel)
        
        self.description = channel.descr
    }
    
    override init(channel: Station1, isSubscribed: Bool) {
        super.init(channel: channel, isSubscribed: isSubscribed)
        
        self.description = channel.descr
    }
}
