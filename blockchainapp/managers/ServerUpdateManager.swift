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

enum StationAction {
	case subscribe
	case unsubscribe
	case report(msg: String)
}

class ServerUpdateManager {
	static let shared = ServerUpdateManager()
    
    let disposeBag = DisposeBag()
	
	func makeStation(id: Int, action: StationAction) {
        let type: ChannelUpdateRequest
        switch action {
        case .subscribe:
            type = .subscribe(count: 1)
        case .unsubscribe:
            type = .subscribe(count: -1)
        case .report(let msg):
            type = .report(msg: msg)
        }
        RequestManager.shared.channelUpdate(id: id, type: type).subscribe(onNext: { (channel) in
            NotificationCenter.default.post(name: InAppUpdateNotification.station.notification(), object: nil, userInfo: ["id" : channel])
        }).disposed(by: disposeBag)
	}
	
	func makeTrack(id: Int, action: TrackAction) {
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
        RequestManager.shared.trackUpdate(id: id, type: type).subscribe(onNext: { (track) in
            NotificationCenter.default.post(name: InAppUpdateNotification.track.notification(), object: nil, userInfo: ["id": track])
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
