import Foundation

enum InAppUpdateNotification: String {
	case track = "TrackUpdate"
	case channel = "StationUpdate"
	case playing = "PlayingStateUpdate"
	case setting = "SettingUpdate"
    case subscription = "SubscriptionChanged"

	func notification() -> NSNotification.Name {
		return NSNotification.Name.init("InAppUpdateNotification"+self.rawValue)
	}
}

protocol TrackUpdateProtocol: class {
	func trackUpdated(track: Track)
}

protocol ChannelUpdateProtocol: class {
	func channelUpdated(channel: Channel)
}

protocol SubscriptionUpdateProtocol: class {
	func channelSubscriptionUpdated()
}

protocol PlayingStateUpdateProtocol: class {
	func trackPlayingUpdate(id: Int, isPlaying: Bool)
}

protocol SettingsUpdateProtocol: class {
	func settingsUpdated()
}

fileprivate class Box {
	weak var value: AnyObject?
	init(_ t: AnyObject) {
		value = t
	}
}

class InAppUpdateManager {
	static let shared = InAppUpdateManager()

    private var observers: [InAppUpdateNotification: [Box]] = [.channel: [],
                                                               .track: [],
                                                               .playing: [],
                                                               .setting: [],
                                                               .subscription: []]
    
	init() {
		NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPlayed(notification:)),
                                               name: AudioController.AudioStateNotification.playing.notification(),
                                               object: nil)
		NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPaused(notification:)),
                                               name: AudioController.AudioStateNotification.paused.notification(),
                                               object: nil)
        
		NotificationCenter.default.addObserver(self,
                                               selector: #selector(settingsChanged(notification:)),
                                               name: InAppUpdateNotification.setting.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(channelChanged(notification:)),
                                               name: InAppUpdateNotification.channel.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackChanged(notification:)),
                                               name: InAppUpdateNotification.track.notification(),
                                               object: nil)

	}

	func subscribe(_ model: AnyObject) -> Bool {
		var result = false
		if let _ = model as? TrackUpdateProtocol {
            self.observers[.track]?.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? ChannelUpdateProtocol {
            self.observers[.channel]?.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? SubscriptionUpdateProtocol {
            self.observers[.subscription]?.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? PlayingStateUpdateProtocol {
            self.observers[.playing]?.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? SettingsUpdateProtocol {
            self.observers[.setting]?.append(Box.init(model))
			result = result || true
		}
		return result
	}
	
	@objc func settingsChanged(notification: Notification) {
		for box in self.observers[.setting] ?? [] {
			(box.value as? SettingsUpdateProtocol)?.settingsUpdated()
		}
	}

	@objc func channelChanged(notification: Notification) {
		if let channel = notification.userInfo?["station"] as? Channel {
			for box in self.observers[.channel] ?? [] {
				(box.value as? ChannelUpdateProtocol)?.channelUpdated(channel: channel)
			}
			for box in self.observers[.subscription] ?? [] {
				(box.value as? SubscriptionUpdateProtocol)?.channelSubscriptionUpdated()
			}
		}
	}
    
    @objc func trackChanged(notification: Notification) {
        if let track = notification.userInfo?["track"] as? Track {
            for box in self.observers[.track] ?? [] {
                (box.value as? TrackUpdateProtocol)?.trackUpdated(track: track)
            }
        }
    }

	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["id"] as? Int {
			for box in self.observers[.playing] ?? [] {
				(box.value as? PlayingStateUpdateProtocol)?.trackPlayingUpdate(id: id, isPlaying: true)
			}
		}
	}

	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["id"] as? Int {
            for box in self.observers[.playing] ?? [] {
				(box.value as? PlayingStateUpdateProtocol)?.trackPlayingUpdate(id: id, isPlaying: false)
			}
		}
	}
}
