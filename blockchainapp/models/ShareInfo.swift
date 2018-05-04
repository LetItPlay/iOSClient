//
//  TrackShareInfo.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ShareInfo {
    var text: String
    var url: String
    var image: UIImage
    
    init(text: String, url: String, image: UIImage) {
        self.text = text
        self.url = url
        self.image = image
    }
}
