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
	var userPlaylist: AudioPlaylist = AudioPlaylist.init()
	var playlist: AudioPlaylist = AudioPlaylist.init()
	var currentTrackIndexPath: IndexPath = IndexPath.init(row: -1, section: -1)
	var info: (current: Double, length: Double) = (current: 0.0, length: 0.0)
	var currentTrack: AudioTrack? {
		get {
			return self[currentTrackIndexPath]
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
		
		let mpcenter = MPRemoteCommandCenter.shared()
		mpcenter.playCommand.isEnabled = true
		mpcenter.pauseCommand.isEnabled = true
		mpcenter.nextTrackCommand.isEnabled = true
		mpcenter.skipBackwardCommand.isEnabled = true
		mpcenter.skipBackwardCommand.preferredIntervals = [10]
		mpcenter.previousTrackCommand.isEnabled = false

		mpcenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.make(command: .play(id: nil))
			return .success
		}

		mpcenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.make(command: .pause)
			return .success
		}

		mpcenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.make(command: .next)
			return .success
		}

		mpcenter.skipBackwardCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.make(command: .seekBackward)
			return .success
		}
//
//		MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//			self.player.make(command: .prev)
//			return .success
//		}
	}
	
	func popupPlayer(show: Bool, animated: Bool) {
		
	}
	
	func make(command: AudioCommand) {
		
		if reach?.connection == Reachability.Connection.none {
			return
		}
		
		switch command {
		case .play(let id):
			if let id = id {
				if let indexPath = indexPath(id: id),
					indexPath != self.currentTrackIndexPath {
					self.currentTrackIndexPath = indexPath
					let index = indexPath.section * userPlaylist.tracks.count + indexPath.item
					player.load(item: (indexPath.section == 0 ? self.userPlaylist.tracks : self.playlist.tracks)[indexPath.item])
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
			DispatchQueue.main.async {
				self.popupDelegate?.popupPlayer(show: true, animated: true)
			}
		case .pause:
			player.make(command: .pause)
		case .next:
			self.play(indexPath: self.currentTrackIndexPath, next: true)
		case .prev:
			self.play(indexPath: self.currentTrackIndexPath, next: false)
		case .seekForward:
			let progress = ( info.current + 10.0 ) / info.length
			let validPregress = progress < 1.0  ? progress : 2.0
			if validPregress < 1.0 {
				self.player.make(command: .seek(progress: validPregress))
			}
		case .seekBackward:
			let newProgress = ( info.current - 10.0 ) / info.length
			player.make(command: .seek(progress: newProgress > 0 ? newProgress : 0.0))
		case .seek(let progress):
			player.make(command: .seek(progress: progress))
		default:
			print("unknown command")
		}
	}
	
	func addToUserPlaylist(track: AudioTrack, inBeginning: Bool) {
		if !self.userPlaylist.tracks.contains(where: {$0.id == track.id}) {
			var userIndexInsert = -1
			if inBeginning {
				
			} else {
				self.userPlaylist.tracks.append(track)
			}
		}
	}
	
	func loadPlaylist(playlist:(String, [AudioTrack]), playId: String?) {
			if self.playlistName != playlist.0 {
				self.currentTrackIndexPath = IndexPath.invalid
				let newPlaylist = AudioPlaylist()
				newPlaylist.tracks = playlist.1
				newPlaylist.name = playlist.0
				self.playlist = newPlaylist
				if let id = playId {
					self.make(command: .play(id: id))
				}
			}
			self.delegate?.playlistChanged()		
	}
	
	func showPlaylist() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.popupDelegate?.showPlaylist()
			self.delegate?.showPlaylist()
		}
	}
	
	func setCurrentTrack(id: String) {
		if let indexPath = indexPath(id: id) {
			let index = indexPath.section * userPlaylist.tracks.count + indexPath.item
			self.player.setTrack(index: index)
		}
	}
	
	func itemFinishedPlaying(id: String) {
		self.play(id: id)
	}
	
	func play(indexPath: IndexPath, next: Bool) {
		let way = next ? 1 : -1
		
		if indexPath.section == 0 {
			if indexPath.item + way == self.userPlaylist.tracks.count {
				self.currentTrackIndexPath = IndexPath.init(row: 0, section: 1)
			} else {
				self.currentTrackIndexPath.item += way
			}
		} else {
			if indexPath.item + way == self.playlist.tracks.count {
				self.make(command: .pause)
				self.currentTrackIndexPath = IndexPath.invalid
				self.userPlaylist.tracks = []
				self.playlist.tracks = []
				// TODO: hide player
			} else {
				self.currentTrackIndexPath.item += way
			}
		}
		if let item = self.currentTrack {
			self.player.load(item: item)
			self.player.make(command: .play)
		}
	}
	
	func play(id: String, next: Bool = true) {
		guard let indexPath = indexPath(id: id) else {
			return
		}
		self.play(indexPath: indexPath, next: next)
	}
	
	func update(time: AudioTime) {
		self.info.current = time.current
		self.info.length = time.length
		DispatchQueue.main.async {
			self.delegate?.updateTime(time: (current: time.current, length: time.length))
		}
	}
	
	func update(status: PlayerStatus, id: String) {
		DispatchQueue.main.async {
			if let indexPath = self.indexPath(id: id) {
				switch status {
				case .paused:
					NotificationCenter.default.post(name: AudioStateNotification.paused.notification(), object: nil, userInfo: ["ItemID": id])
					break
				case .playing:
					self.currentTrackIndexPath = indexPath
					NotificationCenter.default.post(name: AudioStateNotification.playing.notification(), object: nil, userInfo: ["ItemID": id])
					break
				default:
					break
				}
			}
			self.delegate?.playState(isPlaying: self.player.status == .playing)
			self.delegate?.trackUpdate()
		}
	}
	
	private func indexPath(id: String) -> IndexPath? {
		if let mainIndex = self.playlist.tracks.index(where: {$0.id == id}) {
			return IndexPath.init(row: mainIndex, section: 1)
		}
		if let userIndex = self.userPlaylist.tracks.index(where: {$0.id == id}) {
			return IndexPath.init(row: userIndex, section: 0)
		}
		return nil
	}
	
	private func indexPath(index: Int) -> IndexPath? {
		if index < 0 {
			return nil
		}
		if index < userPlaylist.tracks.count {
			return IndexPath.init(row: index, section: 0)
		} else if index < userPlaylist.tracks.count + playlist.tracks.count {
			return IndexPath.init(row: index - userPlaylist.tracks.count , section: 1)
		}
		return nil
	}
	
	private subscript(indexPath: IndexPath) -> AudioTrack? {
		if indexPath.section == 0 {
			if indexPath.item >= 0 && indexPath.item < self.userPlaylist.tracks.count {
				return self.userPlaylist.tracks[indexPath.item]
			}
		} else if indexPath.section == 1 {
			if indexPath.item >= 0 && indexPath.item < self.playlist.tracks.count {
				return self.playlist.tracks[indexPath.item]
			}
		}
		return nil
	}
}
