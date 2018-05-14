

import Foundation
import AVFoundation
import MediaPlayer

fileprivate class PlayerItem: AVPlayerItem, AudioTrack {
	
	var audioURL: URL = URL(fileURLWithPath: "")
	var id: Int = -1
	var name: String = ""
	var author: String = ""
	var imageURL: URL?
	var length: Int64 = 0
	
	override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
		super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
	}
	
	required convenience init(id: Int, trackURL: URL , name: String, author: String, imageURL: URL?, length: Int64) {
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

fileprivate class QueuePlayer: AVPlayer {
	func currentTrack() -> PlayerItem? {
		return self.currentItem as? PlayerItem
	}
}

final class AudioPlayer: NSObject, AudioPlayerProto {
	
	weak var delegate: AudioPlayerDelegate?
	var currentIndex: Int = -1
	
	var status: PlayerStatus = .none
    
    var chosenRate: Float = -1
	
	var error: Error?
	
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"
	private let kTimedMetadataKey = "currentItem.timedMetadata"
	private let kRateKey = "rate"
	private let kErrorKey = "error"
	private let kVolumeKey = "outputVolume"
	
	private var player: QueuePlayer!
	private var audioSession: AVAudioSession!
	private var timeObserver: Any?
	
	override init() {
		super.init()
		
		//--- player settings --//
		player = QueuePlayer()
		//-- session settings --//
		audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryPlayback)
		} catch let error {
			print(error)
		}
		
		player.addObserver(self, forKeyPath: kRateKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kTimedMetadataKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kCurrentItemKey, options: [.initial, .new, .old], context: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(handleRouteChange),
											   name: .AVAudioSessionRouteChange,
											   object: AVAudioSession.sharedInstance())
		
		addPeriodicTimeObserver()
		
		//-- observe the player item "status" key to determine when it is ready to play
		player.addObserver(self,
						   forKeyPath: kStatusKey,
						   options: [.initial, .new],
						   context: nil)
	}
    
    func set(rate: Float) {
        if rate > 0 && rate <= 2 {
            self.chosenRate = rate
            if self.player.rate != 0 {
                self.player.rate = rate
            }
        }
    }
	
	@objc func handleRouteChange(_ notification: Notification) {
		guard let userInfo = notification.userInfo,
			let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
			let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else {
				return
		}
		switch reason {
		case .newDeviceAvailable:
			let session = AVAudioSession.sharedInstance()
			for output in session.currentRoute.outputs where output.portType == AVAudioSessionPortHeadphones {
			}
		case .oldDeviceUnavailable:
			if let previousRoute =
				userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
				let track = self.player.currentTrack(){
				for output in previousRoute.outputs where output.portType == AVAudioSessionPortHeadphones {
					self.status = .paused
					self.delegate?.update(status: .paused, id: track.id)
					break
				}
			}
		default: ()
		}
		
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
//                if let id = self.player.currentTrack()?.id {
//                    self.delegate?.update(status: .playing, id: id)
//                }
				ListenManager.shared.add(id: self.player.currentTrack()?.id ?? -1)
			case .pause:
				self.player.pause()
				self.status = .paused
				if let id = self.player.currentTrack()?.id {
					self.delegate?.update(status: .paused, id: id)
				}
			case .seek(let progress):
				if let item = player.currentTrack(), item.canStepForward {
					let length = Double(CMTimeGetSeconds(self.player.currentItem?.duration ?? kCMTimeZero))
					let current = length * progress
					let time: CMTime = CMTimeMakeWithSeconds(current, 1000)
					self.player.seek(to: time)
					self.delegate?.update(time: (current: current, length: length))
				}
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
        self.player.replaceCurrentItem(with: item)
		if let curr = player.currentTrack(), item.id != curr.id {
			self.player.seek(to: CMTime.init(seconds: 0.0, preferredTimescale: 1))
		}
		self.delegate?.update(time: AudioTime(current: 0.0, length: Double(item.length)))
		self.showLockScreenData()
//		= 0.0
	}
	
	func showLockScreenData() {
		guard let currentItem = player.currentTrack() else {
			return
		}
		
		DispatchQueue.main.async {
			let duration = Double(currentItem.length)
//			let currentTime = CMTimeGetSeconds(currentItem.currentTime())
			
			var infoDict: [String : Any] = [MPMediaItemPropertyPlaybackDuration: duration,
											MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0,
											MPNowPlayingInfoPropertyPlaybackRate: 0.0]
			
			infoDict[MPMediaItemPropertyTitle] = currentItem.name
//			infoDict[MPMediaItemPropertyArtwork] = image
			infoDict[MPMediaItemPropertyArtist] = currentItem.author
			
			MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDict
		}
	}
	
	func setTrack(index: Int) {
		self.currentIndex = index
	}
	
	func clear() {
		self.removeItemsObservers()
		self.player.pause()
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
        
        if self.chosenRate != -1, self.player.rate != 0, self.player.rate != self.chosenRate {
            self.player.rate = self.chosenRate
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
            var dict = [Int: Bool]()
			if let item = change?[NSKeyValueChangeKey.newKey] as? AudioTrack {
				self.delegate?.update(status: self.status, id: item.id)
                dict[item.id] = true
			}
			if let item = change?[NSKeyValueChangeKey.oldKey] as? AudioTrack {
				self.delegate?.update(status: .paused, id: item.id)
                dict[item.id] = self.status == .playing
			}
            self.delegate?.update(items: dict)
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
			
			if let status = self.player.currentItem?.status, duration.isFinite && duration > 0 && status == AVPlayerItemStatus.readyToPlay {
				self.delegate?.update(time: AudioTime(current: current, length: duration) )
				MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = current
			} else {
				MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = current
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
//
//        for item in player.items() {
//            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
//        }
        
        if let item = self.player.currentItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
	}
	
	private func removePlayerItemsErrorObservers() {
//        for item in player.items() {
//            item.removeObserver(self, forKeyPath: kErrorKey)
//        }
	}
	
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		
		player.removeObserver(self, forKeyPath: kRateKey)
		player.removeObserver(self, forKeyPath: kTimedMetadataKey)
		player.removeObserver(self, forKeyPath: kStatusKey)
		player.removeObserver(self, forKeyPath: kCurrentItemKey)
	}
}
