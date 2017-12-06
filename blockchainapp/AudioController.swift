//
//  AudioController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 06/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyAudioManager

enum AudioControllerUpdateNotification: String {
	case playing = "PlayPressed",
	paused = "PausePressed",
	updateProgress = "ProgressUpdated",
	waiting = "Waiting",
	initialize = "Initializing",
	failed = "Failed"
	
	func notification() -> NSNotification.Name {
		return NSNotification.Name.init("AudioControllerUpdateNotification"+self.rawValue)
	}
}

protocol AudioControllerProtocol: class {
	var currentTrackIndex: Int {get}
	var currentTrack: Track? {get}
	var playlist: [Track] {get}
	var status: AudioStatus {get}
	var info: (current: Double, length: Double) {get}
	
	func make(command: AudioCommand)
	
	func setCurrentTrack(index: Int)
	func setCurrentTrack(id: Int)
	func loadPlaylist(playlist:(String, [Track]))
	
	func popupPlayer(show: Bool, animated: Bool)
}

enum AudioStatus {
	case playing, pause, failed, idle
}

enum AudioCommand {
	case play, pause, next, prev, seekForward, seekBackward, seek(progress: Double)
}

class AudioController: AudioControllerProtocol {
	
	let audioManager = AppManager.shared.audioManager
	
	var playlistName: String = "Main"
	var playlist: [Track] = []
	var currentTrackIndex: Int = 0
	var info: (current: Double, length: Double) = (current: 0.0, length: 0.0)
	var currentTrack: Track? {
		get {
			return currentTrackIndex < playlist.count ? playlist[currentTrackIndex] : nil
		}
	}
	var status: AudioStatus {
		get {
			if audioManager.isPlaying {
				return .playing
			}
			if audioManager.isOnPause {
				return .pause
			}
			return .idle
		}
	}
	
	init() {
		subscribe()
	}
	
	func popupPlayer(show: Bool, animated: Bool) {
		
	}
	
	func make(command: AudioCommand) {
		
		switch command {
		case .play:
			if audioManager.currentItem != nil {
				audioManager.resume()
			} else {
				audioManager.playItem(at: currentTrackIndex)
			}
			break
		case .next:
			audioManager.playNext()
			break
		case .prev:
			audioManager.playPrevious()
			break
		case .seekForward:
			let newProgress = ( info.current * info.length - 10.0 ) / info.length
			audioManager.itemProgressPercent = newProgress < 1.0  ? newProgress : 1.0
			break
		case .seekBackward:
			let newProgress = ( info.current * info.length - 10.0 ) / info.length
			audioManager.itemProgressPercent = newProgress > 0 ? newProgress : 0.0
			break
		case .seek(let progress):
			audioManager.itemProgressPercent = progress
			break
		default:
			print("unknown command")
		}
	}
	
	func loadPlaylist(playlist: (String, [Track])) {
		self.playlist = playlist.1
		self.playlistName = playlist.0
		
		let items = self.playlist.map { (track) -> PlayerItem in
			let item = PlayerItem.init(itemId: track.uniqString(), url: track.audiofile?.file.buildImageURL()?.absoluteString ?? "")
			item.artist = track.findStationName() ?? "Various Artist"
			item.title = track.name
			item.autoLoadNext = true
			item.autoPlay = true
			
			return item
		}
		audioManager.resetPlaylistAndStop()
		let group = PlayerItemsGroup.init(id: "42", name: playlist.0, playerItems: items)
		audioManager.add(playlist: [group])
	}
	
	func setCurrentTrack(index: Int) {
		self.currentTrackIndex = index
		audioManager.playItem(at: index)
	}
	
	func setCurrentTrack(id: Int) {
		for i in 0..<playlist.count {
			if playlist[i].id == id {
				setCurrentTrack(index: i)
				break
			}
		}
	}
	
	func subscribe() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerPaused(_:)),
											   name: AudioManagerNotificationName.paused.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerEndPlaying(_:)),
											   name: AudioManagerNotificationName.endPlaying.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerPlaySoundOnSecond(_:)),
											   name: AudioManagerNotificationName.playSoundOnSecond.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerFailed(_:)),
											   name: AudioManagerNotificationName.failed.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerResume(_:)),
											   name: AudioManagerNotificationName.resumed.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerReadyToPlay(_:)),
											   name: AudioManagerNotificationName.readyToPlay.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerRecievedPlay(_:)),
											   name: AudioManagerNotificationName.receivedPlayCommand.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerPreviousPlayed(_:)),
											   name: AudioManagerNotificationName.previousPlayed.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerNextPlayed(_:)),
											   name: AudioManagerNotificationName.nextPlayed.notification,
											   object: audioManager)
	}
	
	// MARK: - AudioManager events
	
	@objc func audioManagerPaused(_ notification: Notification) {
		if audioManager.isOnPause {
			NotificationCenter.default.post(name: AudioControllerUpdateNotification.paused.notification(), object: nil)
		}
	}
	
	@objc func audioManagerEndPlaying(_ notification: Notification) {
		if audioManager.isOnPause {
			NotificationCenter.default.post(name: AudioControllerUpdateNotification.paused.notification(), object: nil)
		}
	}
	
	@objc func audioManagerPlaySoundOnSecond(_ notification: Notification) {

		/*
		let info: [String : Any] = ["itemID" : currentItemId ?? "",
		"currentTime" : currentTime,
		"maxTime": maxTime]
		*/
		if let currentTime = notification.userInfo?["currentTime"] as? Double,
			let maxTime = notification.userInfo?["maxTime"] as? Double {
			self.info.current = currentTime
			self.info.length = maxTime
			NotificationCenter.default.post(name: AudioControllerUpdateNotification.updateProgress.notification(), object: nil)
		}
	}
	
	@objc func audioManagerFailed(_ notification: Notification) {
		NotificationCenter.default.post(name: AudioControllerUpdateNotification.failed.notification(), object: nil)
	}
	
	@objc func audioManagerResume(_ notification: Notification) {
		NotificationCenter.default.post(name: AudioControllerUpdateNotification.playing.notification(), object: nil)
	}
	
	@objc func audioManagerReadyToPlay(_ notification: Notification) {
		NotificationCenter.default.post(name: AudioControllerUpdateNotification.initialize.notification(), object: nil)
	}
	
	@objc func audioManagerNextPlayed(_ notification: Notification) {
		NotificationCenter.default.post(name: AudioControllerUpdateNotification.paused.notification(), object: nil)
	}
	
	@objc func audioManagerPreviousPlayed(_ notification: Notification) {
		NotificationCenter.default.post(name: AudioControllerUpdateNotification.paused.notification(), object: nil)
	}
	
	@objc func audioManagerRecievedPlay(_ notification: Notification) {
		NotificationCenter.default.post(name: AudioControllerUpdateNotification.playing.notification(), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
