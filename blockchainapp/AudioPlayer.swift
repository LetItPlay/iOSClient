

import Foundation
import AVFoundation
import MediaPlayer

fileprivate class PlayerItem: AVPlayerItem, AudioTrack {
	
	var audioURL: URL = URL(fileURLWithPath: "")
	var id: String = UUID.init().uuidString
	var name: String = ""
	var author: String = ""
	var imageURL: URL?
	var length: Int64 = 0
	
	override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
		super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
	}
	
	required convenience init(id: String, trackURL: URL , name: String, author: String, imageURL: URL?, length: Int64) {
		self.init(url: trackURL)
		self.id = id
		self.audioURL = trackURL
		self.name = name
		self.author = author
		self.imageURL = imageURL
		self.length = length
	}
	
	convenience init(track: AudioTrack) {
		let asset = AVAsset.init(url: track.audioURL)
		self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
		self.id = track.id
		self.audioURL = track.audioURL
		self.name = track.name
		self.author = track.author
		self.imageURL = track.imageURL
		self.length = track.length
		
	}
}

fileprivate class AudioPlayer: AVQueuePlayer {
	func currentTrack() -> PlayerItem? {
		return self.currentItem as? PlayerItem
	}
}

final class AudioPlayer2: NSObject, AudioPlayerProto {
	
	weak var delegate: AudioPlayerDelegate1?
	var currentIndex: Int = -1
	
	var status: PlayerStatus = .none
	
	var error: Error?
	
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"
	private let kTimedMetadataKey = "currentItem.timedMetadata"
	private let kRateKey = "rate"
	private let kErrorKey = "error"
	private let kVolumeKey = "outputVolume"
	
	private var player: AudioPlayer!
	private var audioSession: AVAudioSession!
	private var timeObserver: Any?
	
	override init() {
		super.init()
		
		//--- player settings --//
		player = AudioPlayer()
		//-- session settings --//
		audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try audioSession.setCategory(AVAudioSessionCategoryMultiRoute)
			try audioSession.overrideOutputAudioPort(.none)
		} catch let error {
			print(error)
		}
		
		player.addObserver(self, forKeyPath: kRateKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kTimedMetadataKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kCurrentItemKey, options: [.initial, .new, .old], context: nil)
		audioSession.addObserver(self, forKeyPath: kVolumeKey, options: [.initial, .new], context: nil)
		
		addPeriodicTimeObserver()
		
		//-- observe the player item "status" key to determine when it is ready to play
		player.addObserver(self,
						   forKeyPath: kStatusKey,
						   options: [.initial, .new],
						   context: nil)
	}
	
	deinit {
		removePeriodicTimeObserver()
		removeItemsObservers()
		removeObservers()
	}
	
	func make(command: PlayerCommand) {
		switch command {
		case .play:
			self.player.play()
			self.status = .playing
			if let id = self.player.currentTrack()?.id {
				self.delegate?.update(status: .playing, id: id)
			}
		case .pause:
			self.player.pause()
			self.status = .paused
			if let id = self.player.currentTrack()?.id {
				self.delegate?.update(status: .paused, id: id)
			}
		case .seek(let progress):
			let length = Double(CMTimeGetSeconds(self.player.currentItem?.duration ?? kCMTimeZero))
			let current = length * progress
			let time: CMTime = CMTimeMakeWithSeconds(current, 1000)
			self.player.seek(to: time)
			self.delegate?.update(time: (current: current, length: length))
		default:
			break
		}
	}
	
	func load(item: AudioTrack) {
		let item = PlayerItem.init(track: item)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(itemDidFinishPlaying),
											   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
											   object:  item)
		item.addObserver(self,
						  forKeyPath: kErrorKey,
						  options:  [.initial, .new],
						  context: nil)
		self.player.insert(item, after: self.player.currentItem)
		if let curr = player.currentTrack(), item.id != curr.id {
			self.player.advanceToNextItem()
		}
		self.delegate?.update(time: AudioTime(current: 0.0, length: Double(item.length)))
		self.player.play()
	}
	
	func load(playlist: [AudioTrack]) {
		
		player.removeAllItems()
		
		player.actionAtItemEnd = playlist.count == 1 ? .pause : .none
		
		let tracks = playlist.map({PlayerItem.init(track: $0)})
		var previousItem: PlayerItem?
		
		for track in tracks {
			track.addObserver(self,
							 forKeyPath: kErrorKey,
							 options:  [.initial, .new],
							 context: nil)
			player.insert(track, after: previousItem)
			previousItem = track
			
			//--listen finish --//
			NotificationCenter.default.addObserver(self,
												   selector: #selector(itemDidFinishPlaying),
												   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
												   object:  track)
		}
	}
	
	
	func setTrack(index: Int) {
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
			if player.rate >= 1, let _ = player.currentItem {
				if CMTimeGetSeconds(player.currentTime()) < 0.5 {
					//-- начался новый трек --//
//						self.delegate?.audioPlayerStartPlay?(item: currentItem, atIndex: self.player.items().index(of: currentItem) ?? -1)
				} else {
					//-- продолжился старый после паузы
					if let id = self.player.currentTrack()?.id {
						self.delegate?.update(status: .playing, id: id)
					}
					DispatchQueue.main.async {
//						self.delegate?.audioPlayerResumePlay?(item: currentItem, atIndex: self.player.items().index(of: currentItem) ?? -1)
					}
				}
			}
		case kTimedMetadataKey:
			if let itemMetadata = player.currentItem?.timedMetadata {
				for _ in itemMetadata {
//					handleTimedMetadata(timedMetadata: metadataItem)
				}
			}
		case kStatusKey:
			if player.status == AVPlayerStatus.readyToPlay {
//				delegate?.audioReadyToPlay?()
				syncScrubber()
			}
			if player.status == AVPlayerStatus.failed {
				if let id = self.player.currentTrack()?.id {
					self.delegate?.update(status: .paused, id: id)
				}
				self.make(command: .pause)
			}
		case kCurrentItemKey:
			if let item = change?[NSKeyValueChangeKey.newKey] as? AudioTrack, let index = player.items().map({$0 as! AudioTrack}).index(where: {$0.id == item.id}) {
				self.delegate?.update(status: self.status, id: item.id)
				self.currentIndex = index
			}
			if let item = change?[NSKeyValueChangeKey.oldKey] as? AudioTrack {
				self.delegate?.update(status: .paused, id: item.id)
			}
			break
		case kErrorKey:
			if let error = player.currentItem?.error {
				debugPrint(#function, " \(error)")
				self.status = .failed
				if let id = self.player.currentTrack()?.id {
					self.delegate?.update(status: .failed, id: id)
				}
			}
		default:
			print("Audio Player unrecognized event happened!")
		}
	}
	
	@objc private func itemDidFinishPlaying(notification: Notification) {
		if let item = player.currentItem as? AudioTrack {
			DispatchQueue.main.async {
				self.delegate?.itemFinishedPlaying(id: item.id)
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
