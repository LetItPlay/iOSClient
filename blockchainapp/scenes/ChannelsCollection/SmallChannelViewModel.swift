//
//  SmallChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class SmallChannelViewModel {
    var imageURL: URL? = nil
    
    init(channel: Channel)
    {
        self.imageURL = channel.image
    }
}
