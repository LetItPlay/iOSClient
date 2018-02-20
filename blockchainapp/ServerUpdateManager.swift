//
//  ServerUpdateManager.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 20/02/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum TrackAction {
	case like
	case unlike
	case listen
	case report(msg: String)
}

enum StationAction {
	case subscribe
	case unsubscribe
	case report(msg: String)
}

class ServerUpdateManager {
	static let shared = ServerUpdateManager()
	
	func makeStation(id: Int, action: StationAction) {
		
	}
	
	func makeTrack(id: Int, action: TrackAction) {
		
	}
}
