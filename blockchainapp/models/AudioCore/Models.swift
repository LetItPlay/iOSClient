//
//  Models.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 19/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

//MARK: - Enums
// MARK: - Controller Enums
enum AudioStatus {
	case playing, pause, failed, idle
}

enum AudioCommand {
	case play(id: Int?), pause, next, prev, seekForward, seekBackward, seek(progress: Double), volume(value: Double)
}

// MARK: - Player Enums
enum PlayerCommand {
	case play, pause, next, prev, seek(progress: Double)
}

enum PlayerStatus {
	case none, playing, paused, failed
}

typealias AudioTime = (current: Double, length: Double)

//MARK: - Models
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

protocol AudioTrack: class {
	var id: Int {get}
	var name: String {get}
	var author: String {get}
	var imageURL: URL? {get}
	var length: Int64 {get}
	var audioURL: URL {get}
	
	init(id: Int, trackURL: URL, name: String, author: String, imageURL: URL?, length: Int64)
}

class PlayerTrack: AudioTrack {
	var audioURL: URL = URL(fileURLWithPath: "")
	var id: Int = -1
	var name: String = ""
	var author: String = ""
	var imageURL: URL?
	var length: Int64 = 0
	
	required convenience init(id: Int, trackURL: URL , name: String, author: String, imageURL: URL?, length: Int64) {
		self.init()
		self.id = id
		self.audioURL = trackURL
		self.name = name
		self.author = author
		self.imageURL = imageURL
		self.length = length
	}
}

//MARK: - Audio Controller Protocols
protocol AudioControllerDelegate: class {
	func updateTime(time: (current: Double, length: Double))
	func playState(isPlaying: Bool)
	func trackUpdate()
	func playlistChanged()
	func showPlaylist()
}

protocol AudioControllerPresenter: class {
    func popupPlayer(show: Bool, animated: Bool, direction: HideMiniPlayerDirection)
	func showPlaylist()
    func hidePlayer()
}

enum AudioControllerUpdate {
    case reload(tracks: [AudioTrack])
    case remove(id: Int)
    case clearAll(direction: HideMiniPlayerDirection)
}

protocol AudioControllerProtocol: class {
    var delegate: AudioControllerDelegate? {get set}
	
	var currentTrack: AudioTrack? {get}
	var userPlaylist: AudioPlaylist {get}
	var playlist: AudioPlaylist {get}
	var status: AudioStatus {get}
	var info: (current: Double, length: Double) {get}
	
	func make(command: AudioCommand)
	
	func setCurrentTrack(id: Int)
	
	func loadPlaylist(playlist:(String, [AudioTrack]), playId: Int?)

    func update(_ update: AudioControllerUpdate)
}

//MARK: - Audio Player Protocols
protocol AudioPlayerProto {
    var delegate: AudioPlayerDelegate? {get set}
	var currentIndex: Int {get}
	var status: PlayerStatus {get}
	var error: Error? {get}
	
	func make(command: PlayerCommand)
	func load(item: AudioTrack)
	func setPlayingMode(speaker: Bool)
	
	init()
}
