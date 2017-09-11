//
//  File.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

typealias TrackResult = ([Track]) -> Void

protocol FeedPresenterProtocol: class {
    func getData(onComplete: @escaping TrackResult)
    
    func play(track: Track)
    func like(track: Track)
}

protocol FeedViewProtocol: class {
    func display(tracks: [Track])
}
