//
//  AudioController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 06/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import Reachability
import SDWebImage

import UIKit
import MediaPlayer

protocol AudioControllerDelegate: class {
	func updateTime(time: (current: Double, length: Double))
	func volumeUpdate(value: Double)
	func playState(isPlaying: Bool)
	func trackUpdate()
	func playlistChanged()
	func showPlaylist()
}

protocol AudioControllerPresenter: class {
	func popupPlayer(show: Bool, animated: Bool)
	func showPlaylist()
}

class AudioPlaylist {
	var id: String = ""
	var name: String = ""
	var tracks: [AudioTrack] = []
	var length: Int64 {
		get {
			return tracks.map({$0.length}).reduce(0, {$0 + $1})
		}
	}
}

protocol AudioControllerProtocol: class {
	weak var delegate: AudioControllerDelegate? {get set}
	
	var currentTrackIndex: Int {get}
	var currentTrack: AudioTrack? {get}
	var playlist: [AudioTrack] {get}
	var status: AudioStatus {get}
	var info: (current: Double, length: Double) {get}
		
	func make(command: AudioCommand)
	
	func setCurrentTrack(index: Int)
	func setCurrentTrack(id: String)
	
	func loadPlaylist(playlist:(String, [AudioTrack]))
	
	func updatePlaylist()
}

enum AudioStatus {
	case playing, pause, failed, idle
}

enum AudioCommand {
	case play(id: String?), pause, next, prev, seekForward, seekBackward, seek(progress: Double), volume(value: Double)
}

class AudioController: AudioControllerProtocol, AudioPlayerDelegate1 {
	
	enum AudioStateNotification: String {
		case playing = "Playing",
		paused = "Paused",
		loading = "Loading"
		
		func notification() -> NSNotification.Name {
			return NSNotification.Name.init("AudioControllerUpdateNotification"+self.rawValue)
		}
	}
	
	static let main = AudioController()
	
	let player = AudioPlayer2()
	
	weak var delegate: AudioControllerDelegate?
	weak var popupDelegate: AudioControllerPresenter?
	
	var playlistName: String = "Main"
	var playlist: [AudioTrack] = []
	var currentTrackIndex: Int = -1
	var info: (current: Double, length: Double) = (current: 0.0, length: 0.0)
	var currentTrack: AudioTrack? {
		get {
			return currentTrackIndex < playlist.count && currentTrackIndex >= 0 ? playlist[currentTrackIndex] : nil
		}
	}
	var status: AudioStatus {
		get {
			return self.player.status == .playing ? .playing : .pause
		}
	}
	
	let reach: Reachability? = Reachability()
	
	init() {
		
		reach?.whenUnreachable = { _ in
			self.player.make(command: .pause)
		}
		
		do {
			try reach?.startNotifier()
		} catch {
			print("reach doesnt work")
		}
		
		self.player.delegate = self
		
		UIApplication.shared.beginReceivingRemoteControlEvents()
		
		MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.player.make(command: .next)
			return .success
		}
		MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.player.make(command: .prev)
			return .success
		}
	}
	
	func popupPlayer(show: Bool, animated: Bool) {
		
	}
	
	func make(command: AudioCommand) {
		
		if reach?.connection == Reachability.Connection.none {
			return
		}
		
		if self.currentTrackIndex < 0 && self.playlist.count != 0 {
			self.popupDelegate?.popupPlayer(show: true, animated: true)
		}
		
		switch command {
		case .play(let id):
			if let id = id {
				if let index = self.playlist.index(where: {$0.id == id}), index != self.currentTrackIndex {
					player.setTrack(index: index)
					player.make(command: .play)
				} else {
					if player.status == .playing {
						player.make(command: .pause)
					} else {
						player.make(command: .play)
					}
				}
			} else {
				player.make(command: .play)
			}
			self.popupDelegate?.popupPlayer(show: true, animated: true)
		case .pause:
			player.make(command: .pause)
		case .next:
			player.make(command: .next)
		case .prev:
			player.make(command: .prev)
		case .seekForward:
			let newProgress = ( info.current + 10.0 ) / info.length
			player.make(command: .seek(progress: newProgress < 1.0  ? newProgress : 1.0))
		case .seekBackward:
			let newProgress = ( info.current - 10.0 ) / info.length
			player.make(command: .seek(progress: newProgress > 0 ? newProgress : 0.0))
		case .seek(let progress):
			player.make(command: .seek(progress: progress))
		default:
			print("unknown command")
		}
	}
	
	func loadPlaylist(playlist: (String, [AudioTrack])) {
		if self.playlistName != playlist.0 {
			self.playlist = playlist.1
			self.playlistName = playlist.0
			self.player.load(playlist: self.playlist)
			self.player.make(command: .play)
		}
	}
	
	func showPlaylist() {
        self.popupDelegate?.showPlaylist()
        self.delegate?.showPlaylist()
	}
	
	func updatePlaylist() {
	}
	
	func setCurrentTrack(index: Int) {
		if reach?.connection != Reachability.Connection.none {
			if self.currentTrackIndex < 0 {
				self.popupDelegate?.popupPlayer(show: true, animated: true)
			}
			
			self.currentTrackIndex = index
			player.setTrack(index: index)
		}
	}
	
	func setCurrentTrack(id: String) {
		for i in 0..<playlist.count {
			if playlist[i].id == id {
				setCurrentTrack(index: i)
				return
			}
		}
	}
	
	func update(time: AudioTime) {
		self.info.current = time.current
		self.info.length = time.length
		DispatchQueue.main.async {
			self.delegate?.updateTime(time: (current: time.current, length: time.length))
		}
	}
	
	func update(status: PlayerStatus, index: Int) {
		DispatchQueue.main.async {
			switch status {
			case .paused:
				if index != -1 {
					NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": self.playlist[index].id])
				}
				break
			case .playing:
				self.currentTrackIndex = index
				NotificationCenter.default.post(name: AudioStateNotification.playing.notification(), object: nil, userInfo: ["ItemID": self.playlist[index].id])
				break
			default:
				break
			}
			self.delegate?.playState(isPlaying: self.player.status == .playing)
			self.delegate?.trackUpdate()
		}
	}
}
