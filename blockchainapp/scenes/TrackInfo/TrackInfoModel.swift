//
//  TrackInfoModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol TrackInfoModelProtocol: class, ModelProtocol {
    weak var delegate: TrackInfoModelDelegate? {get set}
}

protocol TrackInfoEventHandler {
    func updateTrack(id: Int)
    func trackLiked(id: Int)
    func channelFollowButtonTyped()
}

protocol TrackInfoModelDelegate: class {
    func reload(track: TrackViewModel)
    func reload(channel: SearchChannelViewModel)
    func followUpdate(isSubscribed: Bool)
}

class TrackInfoModel: TrackInfoModelProtocol, TrackInfoEventHandler
{
    weak var delegate: TrackInfoModelDelegate?
    
    var channel: Channel!
    var track: Track!
    
    var tracks: [Track]!
    
    var disposeBag = DisposeBag()
    
    
    init(trackId: Int)
    {
        RequestManager.shared.tracks(req: .allTracks).subscribe(onNext: { (tuple) in
            self.tracks = tuple.0
            self.track = tuple.0.filter({$0.id == trackId}).first
            print(tuple.1.count)
            self.delegate?.reload(track: TrackViewModel(track: self.track))
            self.getChannel()
        }).disposed(by: disposeBag)
        
        InAppUpdateManager.shared.subscribe(self)
    }
    
    func getChannel()
    {
        RequestManager.shared.channel(id: track.channelId).subscribe(onNext: { (channel) in
            self.channel = channel
            let subscriptions = SubscribeManager.shared.channels
            self.channel.isSubscribed = subscriptions.contains(channel.id)
            self.delegate?.reload(channel: SearchChannelViewModel(channel: self.channel))
        }).disposed(by: disposeBag)
    }
    
    func updateTrack(id: Int) {
        if self.tracks != nil {
            self.track = self.tracks.filter({$0.id == id}).first
            self.delegate?.reload(track: TrackViewModel(track: self.track))
            self.getChannel()
        }
    }
    
    func trackLiked(id: Int) {
        let action: TrackAction = track!.isLiked ? TrackAction.unlike : TrackAction.like
        ServerUpdateManager.shared.make(track: track!, action: action)
    }
    
    func channelFollowButtonTyped() {
        // to server
        let action: ChannelAction = channel.isSubscribed ? ChannelAction.unsubscribe : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        // while in User Setting
        SubscribeManager.shared.addOrDelete(channel: self.channel.id)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
}

extension TrackInfoModel: TrackUpdateProtocol, SubscriptionUpdateProtocol {
    func trackUpdated(track: Track) {
        if self.track.id == track.id {
            let vm = TrackViewModel(track: track)
            self.track = track
            self.delegate?.reload(track: vm)
        }
    }
    
    func channelSubscriptionUpdated() {
        let channels: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
        channel.isSubscribed = channels.contains(channel.id)
        
        self.delegate?.followUpdate(isSubscribed: channel.isSubscribed)
    }
}
