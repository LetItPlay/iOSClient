//
//  ServerUpdateManager.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 20/02/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

enum TrackAction {
	case like
	case report(msg: String)
}

enum ChannelAction {
	case subscribe
	case report(msg: String)
    case showHidden
}

class ServerUpdateManager {
	static let shared = ServerUpdateManager()
    
    let disposeBag = DisposeBag()
	
	func make(channel: Channel, action: ChannelAction) {
        let type: ChannelUpdateRequest
        switch action {
        case .subscribe:
            type = channel.isSubscribed ? .unsubscribe : .subscribe
        case .report(let msg):
            type = .report(msg: msg)
        case .showHidden:
            type = .show
        }
        RequestManager.shared.updateChannel(id: channel.id, type: type).subscribe(onNext: { (channel) in
            NotificationCenter.default.post(name: InAppUpdateNotification.channel.notification(), object: nil, userInfo: ["station" : channel])
        }).disposed(by: disposeBag)
	}
	
	func make(track: Track, action: TrackAction) {
        var updatedTrack = track
        let type: TrackUpdateRequest
        print(action)
        switch action {
        case .like:
			LikeManager.shared.addOrDelete(id: track.id)
            updatedTrack.isLiked = LikeManager.shared.hasObject(id: track.id)
            type = track.isLiked ? .dislike : .like
        case .report(let msg):
            type = .report(msg: msg)
        }
		let realm = try? Realm()
		try? realm?.write {
			let obj = TrackObject(track: track)
			realm?.add(obj, update: true)
		}
        
        NotificationCenter.default.post(name: InAppUpdateNotification.track.notification(), object: nil, userInfo: ["track": updatedTrack])
        
		RequestManager.shared.updateTrack(id: track.id, type: type).subscribe(onNext: { (tuple) in
            var track = track
			track.isLiked = LikeManager.shared.hasObject(id: track.id)
            NotificationCenter.default.post(name: InAppUpdateNotification.track.notification(), object: nil, userInfo: ["track": track])
        }).disposed(by: disposeBag)
	}
    
    func update(language: Language) {
        UserSettings.language = language
        NotificationCenter.default.post(name: InAppUpdateNotification.setting.notification(), object: nil, userInfo: ["lang" : UserSettings.language])
    }
    
    func update(contentAge: ContentAge) {
        let isAdult: Bool!
        switch contentAge {
        case .zero:
            isAdult = false
        case .eighteen:
            isAdult = true
        }
        RequestManager.shared.adultContent(set: isAdult)
        NotificationCenter.default.post(name: InAppUpdateNotification.setting.notification(), object: nil, userInfo: ["contentAge" : UserSettings.isAdultContent])
    }
}
