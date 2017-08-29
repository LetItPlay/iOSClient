//
//  MainModels.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

struct Station {
    let name: String
    let image: String
    let subscriptionCount: Int
}

struct Track {
    let station: Int
    let audiofile: Audiofile
    let name: String
    let url: String
    let description: String
    let image: String
    let linkCount: Int
    let reportCount: Int
}

struct Audiofile {
    let file: String
    let lengthSeconds: Int64
    let sizeBytes: Int64
}
