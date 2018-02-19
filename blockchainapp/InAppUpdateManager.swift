import Foundation

enum InAppUpdateNotification: String {
	case track = "TrackUpdate"
	case station = "StationUpdate"
	case playing = "PlayingStateUpdate"
	case setting = "SettingUpdate"
    case subscription = "SubscriptionChanged"

	func notification() -> NSNotification.Name {
		return NSNotification.Name.init("InAppUpdateNotification"+self.rawValue)
	}
}

protocol TrackUpdateProtocol: class {
	func trackUpdated(track: Track1)
}

protocol StationUpdateProtocol: class {
	func stationUpdated(station: Station1)
}

protocol SubscriptionUpdateProtocol: class {
	func stationSubscriptionUpdated()
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

    private var observers: [InAppUpdateNotification: [Box]] = [.station: [],
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
                                               selector: #selector(stationChanged(notification:)),
                                               name: InAppUpdateNotification.station.notification(),
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
		if let _ = model as? StationUpdateProtocol {
            self.observers[.station]?.append(Box.init(model))
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

	@objc func stationChanged(notification: Notification) {
		if let station = notification.userInfo?["station"] as? Station1 {
			for box in self.observers[.station] ?? [] {
				(box.value as? StationUpdateProtocol)?.stationUpdated(station: station)
			}
			for box in self.observers[.subscription] ?? [] {
				(box.value as? SubscriptionUpdateProtocol)?.stationSubscriptionUpdated()
			}
		}
	}
    
    @objc func trackChanged(notification: Notification) {
        if let track = notification.userInfo?["track"] as? Track1 {
            for box in self.observers[.station] ?? [] {
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
