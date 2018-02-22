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
    
    override init(channel: Station) {
        super.init(channel: channel)
        
        self.description = channel.description
    }
    
    override init(channel: Station, isSubscribed: Bool) {
        super.init(channel: channel, isSubscribed: isSubscribed)
        
        self.description = channel.description
    }
}
