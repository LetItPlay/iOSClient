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
}

protocol TrackInfoModelDelegate: class {
    func reload(track: TrackViewModel)
    func reload(channel: SearchChannelViewModel)
}

class TrackInfoModel: TrackInfoModelProtocol, TrackInfoEventHandler
{
    weak var delegate: TrackInfoModelDelegate?
    
    var channel: Channel!
    var track: Track!
    
    var disposeBag = DisposeBag()
    
    
    init(trackId: Int)
    {
        self.updateTrack(id: trackId)
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
        RequestManager.shared.tracks(req: .allTracks).subscribe(onNext: { (tuple) in
            self.track = tuple.0.filter({$0.id == id}).first
            self.delegate?.reload(track: TrackViewModel(track: self.track))
            self.getChannel()
        }).disposed(by: disposeBag)
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
