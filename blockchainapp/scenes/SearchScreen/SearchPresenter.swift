//
//  SearchPresenter.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 13/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum SearchScreenState {
	case search, recommendations
}

protocol SearchPresenterDelegate: class {
	func updateSearch()
	func update(tracks: [Int], channels: [Int])
	func updatePlaylists()
}

class SearchPresenter {
	
	var tracks: [TrackObject] = []
	var channels: [ChannelObject] = []
	weak var delegate: SearchPresenterDelegate?
	let realm: Realm? = try? Realm()
	var currentPlayingIndex: Int = -1
	var playlists: [(image: UIImage?, title: String, descr: String, tracks: [AudioTrack])] = []
	var currentSearchString: String = ""
	
    let disposeBag = DisposeBag()
    
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
		NotificationCenter.default.addObserver(self,
											   selector: #selector(settingsChanged(notification:)),
											   name: SettingsNotfification.changed.notification(),
											   object: nil)
		
		self.getData()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func getData() {
        RequestManager.shared.tracks(req: .magic).subscribe(onNext: { (tuple) in
            let tracklist = tuple.0.map({ (track) -> AudioTrack in
                return PlayerTrack.init(id: track.id, trackURL: track.url!, name: track.name, author: tuple.1.filter({track.channelId == $0.id}).first?.name ?? "", imageURL: track.image, length: track.length)
            })
            self.playlists = [(image: UIImage.init(named: "news"), title: "Fresh news in 30 minutes".localized, descr: "A compilation of fresh news in one 30-minute playlist".localized, tracks: tracklist)]
            self.delegate?.updatePlaylists()
        }).disposed(by: self.disposeBag)

	}
	
	@objc func settingsChanged(notification: Notification) {
		getData()
	}
	
	
	func trackSelected(index: Int) {
		let contr = AudioController.main
		contr.loadPlaylist(playlist: ("Searching".localized, self.playlists[index].tracks), playId: self.playlists[index].tracks[0].id)
	}
	
	func channelSubPressed(index: Int) {
		SubscribeManager.shared.addOrDelete(channel: self.channels[index].id)
	}
	
	func searchChanged(string: String) {
		self.currentSearchString = string
		if string.count == 0 {
			self.tracks = []
			self.channels = []
		} else {
			let tracks = self.realm?.objects(TrackObject.self).filter("name contains[cd] '\(string.lowercased())' OR ANY tags.value CONTAINS[cd] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
            self.tracks = tracks
			self.channels = self.realm?.objects(ChannelObject.self).filter("name contains[cd] '\(string.lowercased())' OR ANY tags.value CONTAINS[cd] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
		}
		self.delegate?.updateSearch()
	}
	
	func formatPlaylists(index: Int) {
		let _ = self.playlists[index]
		let contr = AudioController.main
//        contr.loadPlaylist(playlist: ("Playlist".localized + " \"\(playlist.title)\"", playlist.tracks.map({$0.audioTrack()})), playId: playlist.tracks[0].id)
		contr.showPlaylist()
	}
	
	@objc func subscriptionChanged(notification: Notification) {
		if let id = notification.userInfo?["id"] as? Int,
			let index = self.channels.index(where: {$0.id == id}) {
			self.delegate?.update(tracks: [], channels: [index])
		}
	}
	
	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? String,
			let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
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
		if let id = notification.userInfo?["ItemID"] as? String,
			let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
			let reload = [self.currentPlayingIndex]
			self.currentPlayingIndex = -1
			self.delegate?.update(tracks: reload, channels: [])
		}
	}
}
