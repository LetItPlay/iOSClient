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
    
    init(channel: Station)
    {
        self.imageURL = URL.init(string: channel.image)
    }
}
