//
//  FullChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class FullChannelViewModel: ChannelViewModel {
    var description: String = ""
    
    override init(channel: Station) {
        super.init(channel: channel)
        
        self.description = channel.description
    }
}
