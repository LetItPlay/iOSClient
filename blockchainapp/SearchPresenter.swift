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
	
	var tracks: [Track] = []
	var channels: [Station] = []
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
//        let newsTag = "новости".localized
//
//        if let channels = self.realm?.objects(Station.self).filter("ANY tags.value CONTAINS[cd] '\(newsTag)'").map({$0.id}){
//            var trackSelection = [Track]()
//            for id in channels {
//                if let tracks = self.realm?.objects(Track.self).filter("station = \(id)"){
//                    trackSelection.append(contentsOf: tracks)
//                }
//            }
//            var maxlength: Int64 = 0
//            let filter: (Track) -> Bool = {$0.length <= Int64(4*60) && $0.length > 0 && $0.url != "" && $0.lang == UserSettings.language.rawValue}
//            trackSelection = trackSelection.filter(filter).sorted(by: {$0.publishedAt > $1.publishedAt})
//            var res = [Track]()
//            for track in trackSelection {
//                if maxlength + track.length < Int64(60*33) {
//                    res.append(track.detached())
//                    maxlength += track.length
//                } else {
//                    break
//                }
//            }
//            if res.count > 0 {
//                playlists = [(image: UIImage.init(named: "news"), title: "Fresh news in 30 minutes".localized, descr: "A compilation of fresh news in one 30-minute playlist".localized, tracks: res)]
//            } else {
//                playlists = []
//            }
//            print("res = \(res.map({$0.name}))")
//        }
        RequestManager.shared.tracks(req: .magic).subscribe(onNext: { (tuple) in
            let tracklist = tuple.0.map({ (track) -> AudioTrack in
                return PlayerTrack.init(id: track.idString(), trackURL: track.url!, name: track.name, author: tuple.1.filter({track.stationId == $0.id}).first?.name ?? "", imageURL: URL(string: track.image)!, length: track.length)
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
		SubscribeManager.shared.addOrDelete(station: self.channels[index].id)
	}
	
	func searchChanged(string: String) {
		self.currentSearchString = string
		if string.count == 0 {
			self.tracks = []
			self.channels = []
		} else {
			let tracks = self.realm?.objects(Track.self).filter("name contains[cd] '\(string.lowercased())' OR ANY tags.value CONTAINS[cd] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
            self.tracks = tracks
			self.channels = self.realm?.objects(Station.self).filter("name contains[cd] '\(string.lowercased())' OR ANY tags.value CONTAINS[cd] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
		}
		self.delegate?.updateSearch()
	}
	
	func formatPlaylists(index: Int) {
		
		let playlist = self.playlists[index]
		let contr = AudioController.main
		contr.loadPlaylist(playlist: ("Playlist".localized + " \"\(playlist.title)\"", playlist.tracks.map({$0})), playId: playlist.tracks[0].id)
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
