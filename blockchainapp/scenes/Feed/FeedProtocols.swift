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
	
	var tracks: [Track] {get}
	var playingIndex: Int {get}
	
    func like(trackUID: Int)
	
	func play(index: Int)
	func like(index: Int)
}

protocol FeedViewProtocol: class {
    func display()
	func reload(update: [Int], delete: [Int], insert: [Int])
}
