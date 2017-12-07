//
//  AudioController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 06/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyAudioManager

protocol AudioControllerDelegate: class {
	func updateTime(time: (current: Double, length: Double))
}

protocol AudioControllerProtocol: class {
	weak var delegate: AudioControllerDelegate? {get set}
	
	var currentTrackIndex: Int {get}
	var currentTrack: Track? {get}
	var playlist: [Track] {get}
	var status: AudioStatus {get}
	var info: (current: Double, length: Double) {get}
	
	func make(command: AudioCommand)
	
	func setCurrentTrack(index: Int)
	func setCurrentTrack(id: Int)
	
	func loadPlaylist(playlist:(String, [Track]))
	func updatePlaylist()
	
	func popupPlayer(show: Bool, animated: Bool)
}

enum AudioStatus {
	case playing, pause, failed, idle
}

enum AudioCommand {
	case play(id: Int?), pause, next, prev, seekForward, seekBackward, seek(progress: Double), volume(value: Double)
}

class AudioController: AudioControllerProtocol {
	
	enum AudioStateNotification: String {
		case playing = "Playing",
		paused = "Paused",
		loading = "Loading"
		
		func notification() -> NSNotification.Name {
			return NSNotification.Name.init("AudioControllerUpdateNotification"+self.rawValue)
		}
	}
	
	static let main = AudioController()
	
	let audioManager = AppManager.shared.audioManager
	
	weak var delegate: AudioControllerDelegate?
	
	var playlistName: String = "Main"
	var playlist: [Track] = []
	var currentTrackIndex: Int = -1
	var info: (current: Double, length: Double) = (current: 0.0, length: 0.0)
	var currentTrack: Track? {
		get {
			return currentTrackIndex < playlist.count && currentTrackIndex >= 0 ? playlist[currentTrackIndex] : nil
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
		case .play(let id):
			if let id = id, let index = self.playlist.index(where: {$0.id == id}) {
				audioManager.playItem(at: index)
			} else {
				if audioManager.isPlaying {
					audioManager.pause()
				} else {
					audioManager.resume()
				}
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
		case .volume(let value):
			break
		default:
			print("unknown command")
		}
	}
	
	func loadPlaylist(playlist: (String, [Track])) {
		
		if self.playlistName != playlist.0 {
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
	}
	
	func updatePlaylist() {
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
		if let str = audioManager.currentItemId, let id = Int(str), audioManager.isOnPause {
			NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": id])
		}
	}
	
	@objc func audioManagerEndPlaying(_ notification: Notification) {
		if let str = audioManager.currentItemId, let id = Int(str), audioManager.isOnPause {
			NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": id])
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
		}
	}
	
	@objc func audioManagerFailed(_ notification: Notification) {
	}
	
	@objc func audioManagerResume(_ notification: Notification) {
		if let str = audioManager.currentItemId, let id = Int(str) {
			NotificationCenter.default.post(name: AudioStateNotification.playing.notification(), object: nil, userInfo: ["ItemID": id])
		}
	}
	
	@objc func audioManagerReadyToPlay(_ notification: Notification) {
		print("123")
	}
	
	@objc func audioManagerNextPlayed(_ notification: Notification) {
		if let id = self.currentTrack?.id {
			NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": id])
		}
		if let str = audioManager.currentItemId, let id = Int(str) {
			if let index = self.playlist.index(where: {$0.id == id}) {
				currentTrackIndex = index
			}
			NotificationCenter.default.post(name: AudioStateNotification.playing.notification(), object: nil, userInfo: ["ItemID": id])
		}
	}
	
	@objc func audioManagerPreviousPlayed(_ notification: Notification) {
		if let id = self.currentTrack?.id {
			NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": id])
		}
		if let str = audioManager.currentItemId, let id = Int(str) {
			if let index = self.playlist.index(where: {$0.id == id}) {
				currentTrackIndex = index
			}
			NotificationCenter.default.post(name: AudioStateNotification.playing.notification(), object: nil, userInfo: ["ItemID": id])
		}
	}
	
	@objc func audioManagerRecievedPlay(_ notification: Notification) {
		if currentTrack != nil {
			NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": self.currentTrack?.id])
		}
		
		if let str = audioManager.currentItemId, let id = Int(str) {
			if let index = self.playlist.index(where: {$0.id == id}) {
				currentTrackIndex = index
			}
			NotificationCenter.default.post(name: AudioStateNotification.playing.notification(), object: nil, userInfo: ["ItemID": id])
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
