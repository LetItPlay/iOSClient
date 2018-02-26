//
//  ServerUpdateManager.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 20/02/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

enum TrackAction {
	case like
	case unlike
	case listen
	case report(msg: String)
}

enum ChannelAction {
	case subscribe
	case unsubscribe
	case report(msg: String)
}

class ServerUpdateManager {
	static let shared = ServerUpdateManager()
    
    let disposeBag = DisposeBag()
	
	func make(channel: Channel1, action: ChannelAction) {
        let type: ChannelUpdateRequest
        switch action {
        case .subscribe:
            type = .subscribe(count: 1)
        case .unsubscribe:
            type = .subscribe(count: -1)
        case .report(let msg):
            type = .report(msg: msg)
        }
        RequestManager.shared.updateChannel(id: channel.id, type: type).subscribe(onNext: { (isSub) in
            
        }, onCompleted: {
            var channel = channel
            channel.isSubscribed = !channel.isSubscribed
            NotificationCenter.default.post(name: InAppUpdateNotification.channel.notification(), object: nil, userInfo: ["station" : channel])
        }).disposed(by: disposeBag)
	}
	
	func make(track: Track1, action: TrackAction) {
        let type: TrackUpdateRequest
        switch action {
        case .listen:
            type = .listen
        case .like:
            type = .like(count: 1)
        case .unlike:
            type = .like(count: -1)
        case .report(let msg):
            type = .report(msg: msg)
        }
        RequestManager.shared.updateTrack(id: track.id, type: type).subscribe(onNext: { (tuple) in
            var track = track
            track.likeCount = tuple.0
            track.reportCount = tuple.1
            track.listenCount = tuple.2
            NotificationCenter.default.post(name: InAppUpdateNotification.track.notification(), object: nil, userInfo: ["track": track])
        }).disposed(by: disposeBag)
	}
    
    func updateLanguage()
    {
        switch UserSettings.language {
        case .ru:
            UserSettings.language = .en
        case .en:
            UserSettings.language = .ru
        default:
            UserSettings.language = .none
        }
        
        NotificationCenter.default.post(name: InAppUpdateNotification.setting.notification(), object: nil, userInfo: ["lang" : UserSettings.language])
    }
}
