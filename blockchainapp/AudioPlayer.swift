

import Foundation
import AVFoundation
import MediaPlayer

enum PlayerCommand {
	case play, pause, next, prev, seek(progress: Double)
}

enum PlayerStatus {
	case none, playing, paused, failed
}

typealias AudioTime = (current: Double, length: Double)

class AudioTrack: AVPlayerItem {
	var id: Int = -1
	var name: String = ""
	var author: String = ""
	var image: UIImage?
	var length: Int64 = 0
	
	convenience init(track: Track) {
		self.init(url: track.audiofile!.file.buildImageURL()!)
		self.id = track.id
		self.name = track.name
		self.author = track.findStationName() ?? ""
		self.length = track.audiofile?.lengthSeconds ?? 0
	}
}

protocol AudioPlayerProto {
	weak var delegate: AudioPlayerDelegate1? {get set}
	var currentIndex: Int {get}
	var status: PlayerStatus {get}
	var error: Error? {get}
	
	func make(command: PlayerCommand)
	func load(playlist: [Track])
	func setTrack(index: Int)
	func clear()
	func setPlayingMode(speaker: Bool)
	
	init()
}

protocol AudioPlayerDelegate1: class {
	func update(status: PlayerStatus, index: Int)
	func update(time: AudioTime)
}

final class AudioPlayer2: NSObject, AudioPlayerProto {
	
	weak var delegate: AudioPlayerDelegate1?
	var currentIndex: Int = -1
//	{
//		get{
//			return self.player.items().map({$0 as! AudioTrack}).index(where: { $0.id == (self.player.currentItem as! AudioTrack).id }) ?? -1
//		}
//	}
	
	var status: PlayerStatus = .none
	
	var error: Error?
	
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"
	private let kTimedMetadataKey = "currentItem.timedMetadata"
	private let kRateKey = "rate"
	private let kErrorKey = "error"
	private let kVolumeKey = "outputVolume"
	
	private var player: AVQueuePlayer!
	private var audioSession: AVAudioSession!
	private var timeObserver: Any?
	
	override init() {
		super.init()
		
		//--- player settings --//
		player = AVQueuePlayer()
		//-- session settings --//
		audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
		} catch let error {
			print(error)
		}
		
		player.addObserver(self, forKeyPath: kRateKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kTimedMetadataKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kCurrentItemKey, options: [.initial, .new, .old], context: nil)
		audioSession.addObserver(self, forKeyPath: kVolumeKey, options: [.initial, .new], context: nil)
		
		addPeriodicTimeObserver()
	}
	
	deinit {
		removePeriodicTimeObserver()
		removeItemsObservers()
		removeObservers()
	}
	
	func make(command: PlayerCommand) {
		switch command {
		case .next:
			if self.currentIndex == player.items().count - 1 {
				self.player.pause()
				self.delegate?.update(status: .paused, index: self.currentIndex)
			} else {
				self.delegate?.update(status: .paused, index: self.currentIndex)
				self.currentIndex += 1
				self.setTrack(index: self.currentIndex)
//				self.player.advanceToNextItem()
				self.delegate?.update(status: .playing, index: self.currentIndex)
			}
		case .prev:
			if self.currentIndex == 0 {
				self.player.seek(to: kCMTimeZero)
//				self.player.pause()
//				self.delegate?.update(status: .paused, index: self.currentIndex)
			} else {
				self.delegate?.update(status: .paused, index: self.currentIndex)
				self.currentIndex -= 1
				self.setTrack(index: self.currentIndex)
				self.delegate?.update(status: .playing, index: self.currentIndex)
			}
		case .play:
			self.player.play()
			self.status = .playing
			self.delegate?.update(status: .playing, index: self.currentIndex)
		case .pause:
			self.player.pause()
			self.status = .paused
			self.delegate?.update(status: .paused, index: self.currentIndex)
		case .seek(let progress):
			let length = Double(CMTimeGetSeconds(self.player.currentItem?.duration ?? kCMTimeZero))
			let current = length * progress
			let time: CMTime = CMTimeMakeWithSeconds(current, 1000)
			self.player.seek(to: time)
			self.delegate?.update(time: (current: current, length: length))
		}
	}
	
	func load(playlist: [Track]) {
		self.currentIndex = 0
		removePlayerItemsErrorObservers()
		
		for item in player.items() {
			NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
		}
		
		player.removeAllItems()
		
		player.actionAtItemEnd = playlist.count == 1 ? .pause : .none
		
		var previousItem: AudioTrack?
		
		for track in playlist {
			let item = AudioTrack(track: track)
			item.addObserver(self,
							 forKeyPath: kErrorKey,
							 options:  [.initial, .new],
							 context: nil)
			player.insert(item, after: previousItem)
			previousItem = item
			
			//--listen finish --//
			NotificationCenter.default.addObserver(self,
												   selector: #selector(itemDidFinishPlaying),
												   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
												   object:  item)
		}
		//-- observe the player item "status" key to determine when it is ready to play
		player.addObserver(self,
						   forKeyPath: kStatusKey,
						   options: [.initial, .new],
						   context: nil)
	}
	
	
	func setTrack(index: Int) {
		let status = self.status
		self.player.pause()
		guard index < self.player.items().count else {
			return
		}
		
		let tracks = self.player.items()
		self.player.removeAllItems()
		
		var previousItem: AVPlayerItem?
		for track in tracks {
			player.insert(track, after: previousItem)
			previousItem = track
		}
		for _ in 0..<index {
			self.player.advanceToNextItem()
		}
		
		switch status {
		case .playing:
			self.delegate?.update(status: .paused, index: self.currentIndex)
			self.player.play()
			self.delegate?.update(status: .playing, index: index)
		case .paused:
			self.player.pause()
		default:
			break
		}
		self.currentIndex = index
	}
	
	func clear() {
		self.removeItemsObservers()
		self.player.removeAllItems()
	}
	
	func setPlayingMode(speaker: Bool) {
		do {
			try audioSession.overrideOutputAudioPort(speaker ? AVAudioSessionPortOverride.speaker : AVAudioSessionPortOverride.none)
		} catch {
			print("audioSession error: \(error.localizedDescription)")
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		guard let keyPath = keyPath else {
			return
		}
		
		switch keyPath {
		case kRateKey:
			if player.rate >= 1, let currentItem = player.currentItem {
				if CMTimeGetSeconds(player.currentTime()) < 0.5 {
					//-- начался новый трек --//
//						self.delegate?.audioPlayerStartPlay?(item: currentItem, atIndex: self.player.items().index(of: currentItem) ?? -1)
				} else {
					//-- продолжился старый после паузы
					self.delegate?.update(status: .playing, index: self.currentIndex)
					DispatchQueue.main.async {
//						self.delegate?.audioPlayerResumePlay?(item: currentItem, atIndex: self.player.items().index(of: currentItem) ?? -1)
					}
				}
			}
		case kTimedMetadataKey:
			if let itemMetadata = player.currentItem?.timedMetadata {
				for metadataItem in itemMetadata {
//					handleTimedMetadata(timedMetadata: metadataItem)
				}
			}
		case kStatusKey:
			if player.status == AVPlayerStatus.readyToPlay {
//				delegate?.audioReadyToPlay?()
				syncScrubber()
			}
			if player.status == AVPlayerStatus.failed {
				self.delegate?.update(status: .paused, index: currentIndex)
				self.make(command: .pause)
			}
		case kCurrentItemKey:
			if let item = change?[NSKeyValueChangeKey.newKey] as? AudioTrack, let index = player.items().index(of: item) {
				self.delegate?.update(status: self.status, index: currentIndex)
				self.currentIndex = index
				print(item.duration)
			}
			if let item = change?[NSKeyValueChangeKey.oldKey] as? AudioTrack {
				self.delegate?.update(status: .paused, index: self.currentIndex)
				print(item.duration)
			}
			break
		case kErrorKey:
			if let error = player.currentItem?.error {
				debugPrint(#function, " \(error)")
				self.status = .failed
				self.delegate?.update(status: .failed, index: self.currentIndex)
			}
		default:
			print("Audio Player unrecognized event happened!")
		}
	}
	
	@objc private func itemDidFinishPlaying(notification: Notification) {
		if let currentItem = player.currentItem {
			DispatchQueue.main.async {
//				self.delegate?.audioPlayerFinishPlay?(item: currentItem, atIndex: self.player.items().index(of: currentItem) ?? -1)
			}
		}
	}
	
	private func addPeriodicTimeObserver() {
		// Invoke callback every half second
		let interval = CMTime(seconds: 0.1,
							  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		// Add time observer
		timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
			self?.syncScrubber()
		}
	}
	
	/* Set the scrubber based on the player current time. */
	private func syncScrubber() {
		if let playerDuration = self.player.currentItem?.duration, CMTIME_IS_VALID(playerDuration) {
			let duration = Double(CMTimeGetSeconds(playerDuration))
			let current = Double(CMTimeGetSeconds(player.currentTime()))
			
			if duration.isFinite && duration > 0 {
				self.delegate?.update(time: AudioTime(current: current, length: duration) )
			}
		}
	}
	
	private func removePeriodicTimeObserver() {
		// If a time observer exists, remove it
		if let token = timeObserver {
			player.removeTimeObserver(token)
			timeObserver = nil
		}
	}
	
	private func removeItemsObservers() {
		removePlayerItemsErrorObservers()
		
		for item in player.items() {
			NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
		}
	}
	
	private func removePlayerItemsErrorObservers() {
		for item in player.items() {
			item.removeObserver(self, forKeyPath: kErrorKey)
		}
	}
	
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		
		player.removeObserver(self, forKeyPath: kRateKey)
		player.removeObserver(self, forKeyPath: kTimedMetadataKey)
		player.removeObserver(self, forKeyPath: kStatusKey)
		player.removeObserver(self, forKeyPath: kCurrentItemKey)
	}
}
