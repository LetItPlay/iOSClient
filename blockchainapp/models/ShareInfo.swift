//
//  TrackShareInfo.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

enum ShareObjectType {
    case track, channel
}

class ShareInfo {
    var id: Int
    
    var type: ShareObjectType
    
    var text: String
    var url: String
    var image: UIImage
    
    init(id: Int, type: ShareObjectType, text: String, url: String, image: UIImage) {
        self.id = id
        self.type = type
        self.text = text
        self.url = url
        self.image = image
    }
}
