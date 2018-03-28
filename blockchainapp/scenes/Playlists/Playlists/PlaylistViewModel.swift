//
//  PlaylistViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

struct PlaylistViewModel {
    var imageURL: Data? = nil
    var title: String = ""
    var description: String = ""
    
    init(image: Data, title: String, description: String)
    {
        self.imageURL = image
        self.title = title
        self.description = description
    }
}
