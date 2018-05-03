//
//  CategoryChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 03.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class CategoryChannelViewModel: SmallChannelViewModel {
    var name: String = ""
    
    override init(channel: Channel) {
        super.init(channel: channel)
        
        self.name = channel.name
    }
}
