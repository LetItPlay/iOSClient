

import Foundation
import AVFoundation
import MediaPlayer
import SDWebImage

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

protocol AudioPlayerDelegate: class {
    func update(items: [Int: Bool])
    func updateStatus()
    func update(time: AudioTime)
    func itemFinishedPlaying(id: Int)
}

final class AudioPlayer: NSObject {
	
	weak var delegate: AudioPlayerDelegate?
	var currentIndex: Int = -1
    var currentOp: SDWebImageOperation?

	var status: PlayerStatus = .none
    
    var chosenRate: Float = 1.0
	
	var error: Error?
	
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"
	private let kTimedMetadataKey = "currentItem.timedMetadata"
	private let kRateKey = "rate"
	private let kErrorKey = "error"
	private let kVolumeKey = "outputVolume"
	
	private var player: QueuePlayer = QueuePlayer()
	private var audioSession: AVAudioSession!
	private var timeObserver: Any?
	
	override init() {
		super.init()
        
        audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryPlayback)
		} catch let error {
			print(error)
		}
        
		player.addObserver(self, forKeyPath: kRateKey, options: [.initial, .new], context: nil)
//        player.addObserver(self, forKeyPath: kTimedMetadataKey, options: [.initial, .new], context: nil)
		player.addObserver(self, forKeyPath: kCurrentItemKey, options: [.initial, .new, .old], context: nil)
        player.addObserver(self, forKeyPath: kStatusKey, options: [.initial, .new], context: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(handleRouteChange),
											   name: .AVAudioSessionRouteChange,
											   object: AVAudioSession.sharedInstance())
		
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, 1000), queue: nil) {[weak self] (time) in
            if let playerDuration = self?.player.currentItem?.duration, CMTIME_IS_VALID(playerDuration) {
                let duration = Double(CMTimeGetSeconds(playerDuration))
                let current = Double(CMTimeGetSeconds(time))
                
                if let status = self?.player.currentItem?.status, duration.isFinite && duration > 0 && status == AVPlayerItemStatus.readyToPlay {
                    self?.delegate?.update(time: AudioTime(current: current, length: duration) )
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = current
                } else {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = current
                }
            }
        }
        

	}
    
    deinit {
        self.removeObservers()
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
					self.delegate?.updateStatus()
					break
				}
			}
		default: ()
		}
		
	}
    
	func showLockScreenData() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = currentTrackDict(image: nil)
        self.currentOp = SDWebImageManager.shared().loadImage(with: self.player.currentTrack()?.imageURL, options: SDWebImageOptions.highPriority, progress: nil) {[self] (image, data, error, type, comp, url) in
            if let image = image {
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork]
                    = MPMediaItemArtwork.init(boundsSize: CGSize.init(width: 300, height: 300), requestHandler: { (size) -> UIImage in
                        return image
                    })
            }
        }
	}
    
    private func currentTrackDict(image: UIImage?) -> [String: Any] {
        guard let currentItem = player.currentTrack() else {
            return [:]
        }
        let duration = Double(currentItem.length)
        
        var infoDict: [String : Any] = [MPMediaItemPropertyPlaybackDuration: duration,
                                        MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0,
                                        MPNowPlayingInfoPropertyPlaybackRate: 0.0]
        
        infoDict[MPMediaItemPropertyTitle] = currentItem.name
            infoDict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: CGSize.init(width: 300, height: 300), requestHandler: { (size) -> UIImage in
                return UIImage.init(named: "trackPlaceholder")!
            })
        infoDict[MPMediaItemPropertyArtist] = currentItem.author
        
        return infoDict
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
				} else {
					if let id = self.player.currentTrack()?.id {
                        self.status = .playing
                        self.delegate?.updateStatus()
                        self.delegate?.update(items: [id: true])
					}
				}
			}
		case kStatusKey:
            switch player.status {
                case .readyToPlay:
                    break
                case .failed:
                    if let id = self.player.currentTrack()?.id {
                        self.delegate?.update(items: [id: false])
                    }
                    self.make(command: .pause)
                default:
                    break
            }
		case kCurrentItemKey:
            var dict = [Int: Bool]()
			if let item = change?[NSKeyValueChangeKey.newKey] as? AudioTrack {
                dict[item.id] = true
			}
			if let item = change?[NSKeyValueChangeKey.oldKey] as? AudioTrack {
                dict[item.id] = self.status == .playing
			}
            self.delegate?.update(items: dict)
			break
		case kErrorKey:
			if let error = player.currentItem?.error {
				debugPrint(#function, " \(error)")
				self.status = .failed
				if let id = self.player.currentTrack()?.id {
                    self.delegate?.update(items: [id: false])
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
    
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		
		player.removeObserver(self, forKeyPath: kRateKey)
		player.removeObserver(self, forKeyPath: kTimedMetadataKey)
		player.removeObserver(self, forKeyPath: kStatusKey)
		player.removeObserver(self, forKeyPath: kCurrentItemKey)
	}
}

extension AudioPlayer: AudioPlayerProto {
    
    func make(command: PlayerCommand) {
        switch command {
        case .play:
            self.player.play()
            self.status = .playing
            ListenManager.shared.add(id: self.player.currentTrack()?.id ?? -1)
        case .pause:
            self.player.pause()
            self.status = .paused
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
        self.delegate?.updateStatus()
    }
    
    func load(item: AudioTrack) {
        currentOp?.cancel()
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
    }
    
    func set(rate: Float) {
        if rate > 0 && rate <= 2 {
            self.chosenRate = rate
            self.player.rate = rate
        }
    }
    
}
