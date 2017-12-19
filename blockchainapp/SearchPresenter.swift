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
	func updateSearch()
	func update(tracks: [Int], channels: [Int])
}

class SearchPresenter {
	
	var tracks: [Track] = []
	var channels: [Station] = []
	weak var delegate: SearchPresenterDelegate?
	let realm: Realm? = try? Realm()
	var currentPlayingIndex: Int = -1
	var playlists: [(image: UIImage?, title: String, descr: String)] = []
	var currentSearchString: String = ""
	
	init() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(subscriptionChanged(notification:)),
											   name: SubscribeManager.NotificationName.added.notification,
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(subscriptionChanged(notification:)),
											   name: SubscribeManager.NotificationName.deleted.notification,
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPlayed(notification:)),
											   name: AudioController.AudioStateNotification.playing.notification(),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPaused(notification:)),
											   name: AudioController.AudioStateNotification.paused.notification(),
											   object: nil)
		
		playlists.append((image: UIImage.init(named: "news"), title: "Fresh news in 30 minutes".localized, descr: "A compilation of fresh news in one 30-minute playlist".localized))
//		playlists.append((image: nil, title: "IT", descr: "Новост\nНовости"))
//		playlists.append((image: nil, title: "Спорт", descr: "Новост\nНовости"))
		NotificationCenter.default.addObserver(self,
											   selector: #selector(settingsChanged(notification:)),
											   name: SettingsNotfification.changed.notification(),
											   object: nil)    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func settingsChanged(notification: Notification) {
		self.searchChanged(string: currentSearchString)
	}
	
	
	func trackSelected(index: Int) {
		let contr = AudioController.main
		if contr.currentTrackIndex != index {
			contr.loadPlaylist(playlist: ("Player", self.tracks))
			contr.setCurrentTrack(index: index)
		}
	}
	
//	func channelSelected(index: Int) {
//
//	}
	
	func channelSubPressed(index: Int) {
		SubscribeManager.shared.addOrDelete(station: self.channels[index].id)
	}
	
	func searchChanged(string: String) {
		self.currentSearchString = string
		if string.count == 0 {
			self.tracks = []
			self.channels = []
		} else {
			self.tracks = self.realm?.objects(Track.self).filter("name contains[c] '\(string.lowercased())' OR tagString contains[c] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
			self.channels = self.realm?.objects(Station.self).filter("name contains[c] '\(string.lowercased())' OR tagString contains[c] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
		}
		self.delegate?.updateSearch()
	}
	
	func formatPlaylists(index: Int) {
		
		let tags = ["новости", "IT", "спорт"]
		
		if let channels = self.realm?.objects(Station.self).filter("tagString CONTAINS '\(tags[index])'").map({$0.id}){
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
				if let length = track.audiofile?.lengthSeconds, length < Int64(7*60), track.audiofile?.file != "" || track.audiofile?.file != nil, track.lang == UserSettings.language.rawValue {
					if maxlength + length < Int64(60*33) {
						res.append(track)
						maxlength += length
					} else {
						break
					}
				}
			}
			if res.count > 0 {
				let contr = AudioController.main
				contr.loadPlaylist(playlist: ("Playlist \"\(tags[index])\"", res))
				contr.setCurrentTrack(index: 0)
				contr.showPlaylist()
			}
			print("res = \(res.map({$0.name}))")
		}
	}
	
	@objc func subscriptionChanged(notification: Notification) {
		if let id = notification.userInfo?["id"] as? Int,
			let index = self.channels.index(where: {$0.id == id}) {
			self.delegate?.update(tracks: [], channels: [index])
		}
	}
	
	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int,
			let index = self.tracks.index(where: {$0.id == id}) {
			var reload = [Int]()
			if currentPlayingIndex != -1 {
				reload.append(self.currentPlayingIndex)
			}
			self.currentPlayingIndex = index
			reload.append(index)
			self.delegate?.update(tracks: reload, channels: [])
			
		}
	}
	
	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int,
			let index = self.tracks.index(where: {$0.id == id}) {
			let reload = [self.currentPlayingIndex]
			self.currentPlayingIndex = -1
			self.delegate?.update(tracks: reload, channels: [])
		}
	}
}
