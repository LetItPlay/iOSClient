//
//  File.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

typealias TrackResult = ([TrackObject]) -> Void

protocol FeedPresenterProtocol: class {
    func getData(onComplete: @escaping TrackResult)
	
	var tracks: [TrackObject] {get}
	var playingIndex: Int {get}
	
    func like(trackUID: Int)
	
	func play(index: Int)
	func like(index: Int)
	func addTrack(toBeggining: Bool, for index: Int)
}

protocol FeedViewProtocol: class {
    func display()
	func reload(update: [Int], delete: [Int], insert: [Int])
}
