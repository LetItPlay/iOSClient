//
//  SearchPresenter.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 13/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

enum SearchScreenState {
	case search, recommendations
}

protocol SearchPresenterDelegate: class {
	func show(state: SearchScreenState)
	func updateSearch()
}

class SearchPresenter {
	
	var tracks: [Track] = []
	var channels: [Station] = []
	weak var delegate: SearchPresenterDelegate?
	let realm: Realm? = try? Realm()
	
	init() {
		
	}
	
	func searchChanged(string: String) {
		if string.count == 0 {
			delegate?.show(state: .recommendations)
			self.tracks = []
			self.channels = []
		} else {
			self.tracks = self.realm?.objects(Track.self).filter("name CONTAINS '\(string)' OR tagString CONTAINS '\(string)'").map({$0}) ?? []
			self.channels = self.realm?.objects(Station.self).filter("name CONTAINS '\(string)' OR tagString CONTAINS '\(string)'").map({$0}) ?? []
		}
		self.delegate?.updateSearch()
	}
	
	func formatPlaylists() {
		
		let tags = ["новости", "IT", "юмор"]
		
		for tag in tags {
			if let channels = self.realm?.objects(Station.self).filter("tagString CONTAINS '\(tag)'").map({$0.id}){
				var trackSelection = [Track]()
				for id in channels {
					if let tracks = self.realm?.objects(Track.self).filter("station = \(id)"){
						trackSelection.append(contentsOf: tracks)
					}
				}
				var maxlength: Int64 = 0
				trackSelection = trackSelection.sorted(by: {$0.publishedAt > $1.publishedAt})
				var res = [Track]()
				for track in trackSelection {
					if let length = track.audiofile?.lengthSeconds, length < Int64(7*60)  {
						if maxlength + length < Int64(60*33) {
							res.append(track)
							maxlength += length
						} else {
							break
						}
					}
				}
				print("res = \(res.map({$0.name}))")
			}
		}
	}
}
