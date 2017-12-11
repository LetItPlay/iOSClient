//
//  ChannelPresenter.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 11/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChannelPresenterDelegate: class {
	func followUpdate()
}

class ChannelPresenter {
	
	var tracks: [[Track]] = []
	var token: NotificationToken?
	var station: Station!
	var currentTrackID: Int?
	
	weak var view: ChannelViewController?
	
	var subManager = SubscribeManager.shared
	
	init(station: Station) {
		
		self.station = station
		let realm = try! Realm()
		let results = realm.objects(Track.self).sorted(byKeyPath: "publishedAt", ascending: false)
		
		token = results.observe({ [weak self] (changes: RealmCollectionChange) in
			let filter: (Track) -> Bool = {$0.station == self?.station.id}
			let currentID = AudioController.main.currentTrack?.id
			switch changes {
			case .initial:
				// Results are now populated and can be accessed without blocking the UI
				self?.tracks = [Array(results).filter(filter)]
				
			case .update(_, let deletions, let insertions, let modifications):
				// Query results have changed, so apply them to the UITableView
				self?.tracks = [Array(results).filter(filter)]
				
				
			case .error(let error):
				// An error occurred while opening the Realm file on the background worker thread
				fatalError("\(error)")
			}
			self?.view?.update()
		})
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPlayed(notification:)),
											   name: AudioController.AudioStateNotification.playing.notification(),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPaused(notification:)),
											   name: AudioController.AudioStateNotification.paused.notification(),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(subscribed(notification:)),
											   name: SubscribeManager.NotificationName.added.notification,
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(unsubscribed(notification:)),
											   name: SubscribeManager.NotificationName.deleted.notification,
											   object: nil)
				
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		token?.invalidate()
	}
	
	func followPressed() {
		subManager.addOrDelete(station: self.station.id)
	}
	
	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int, let index = self.tracks.first?.index(where: {$0.id == id}) {
			self.view?.currentIndex = index
			self.view?.update()
		}
	}
	
	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int, let index = self.tracks.first?.index(where: {$0.id == id}) {
			self.view?.currentIndex = -1
			self.view?.update()
		}
	}
	
	@objc func subscribed(notification: Notification) {
		self.view?.followUpdate()
	}
	
	@objc func unsubscribed(notification: Notification) {
		self.view?.followUpdate()
	}
}
