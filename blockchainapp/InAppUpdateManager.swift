import Foundation

enum InAppUpdateNotification: String {
	case track = "TrackUpdate"
	case channel = "ChannelUpdate"
	case playing = "PlayingStateUpdate"
	case setting = "SettingUpdate"

	func notification() -> NSNotification.Name {
		return NSNotification.Name.init("InAppUpdateNotification"+self.rawValue)
	}
}

enum UpdateType {
	case track, station, subscription
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

	private var trackObservers: [Box] = []
	private var stationObservers: [Box] = []
	private var subscriptionObservers: [Box] = []
	private var playingObservers: [Box] = []
	private var settingsObservers: [Box] = []

	init() {

		NotificationCenter.default.addObserver(self,
				selector: #selector(subscriptionChanged(notification:)),
				name: SubscribeManager.NotificationName.added.notification,
				object: nil)
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
				name: SettingsNotfification.changed.notification(),
				object: nil)

	}

	func subscribe(_ model: AnyObject) -> Bool {
		var result = false
		if let _ = model as? TrackUpdateProtocol {
			self.trackObservers.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? StationUpdateProtocol {
			self.stationObservers.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? SubscriptionUpdateProtocol {
			self.subscriptionObservers.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? PlayingStateUpdateProtocol {
			self.playingObservers.append(Box.init(model))
			result = result || true
		}
		if let _ = model as? SettingsUpdateProtocol {
			self.settingsObservers.append(Box.init(model))
			result = result || true
		}
		return result
	}
	
	@objc func settingsChanged(notification: Notification) {
		for box in self.settingsObservers {
			(box.value as? SettingsUpdateProtocol)?.settingsUpdated()
		}
	}

	@objc func subscriptionChanged(notification: Notification) {
		if let station = notification.userInfo?["Station"] as? Station1 {
			for box in self.subscriptionObservers {
				(box.value as? StationUpdateProtocol)?.stationUpdated(station: station)
			}

			for box in self.subscriptionObservers {
				(box.value as? SubscriptionUpdateProtocol)?.stationSubscriptionUpdated()
			}
		}
	}

	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["id"] as? Int {
			for box in self.settingsObservers {
				(box.value as? PlayingStateUpdateProtocol)?.trackPlayingUpdate(id: id, isPlaying: true)
			}
		}
	}

	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["id"] as? Int {
			for box in self.settingsObservers {
				(box.value as? PlayingStateUpdateProtocol)?.trackPlayingUpdate(id: id, isPlaying: false)
			}
		}
	}
}
