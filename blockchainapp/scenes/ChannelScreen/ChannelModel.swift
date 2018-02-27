//
//  ChannelVCModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Action

protocol ChannelModelProtocol: class, ModelProtocol {
    weak var delegate: ChannelModelDelegate? {get set}
}

protocol ChannelEvenHandler: class {
    func followPressed()
    func set(channel: Channel)
}

protocol ChannelModelDelegate: class {
    func reload(tracks: [TrackViewModel])
    func trackUpdate(index: Int, vm: TrackViewModel)
    func followUpdate(isSubscribed: Bool)
    func getChannel(channel: FullChannelViewModel)
}

class ChannelModel: ChannelModelProtocol, ChannelEvenHandler {
    
    var delegate: ChannelModelDelegate?
    
    var tracks: [Track] = []
    var channel: Channel!
    var currentTrackID: Int?
    
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    var subManager = SubscribeManager.shared
	
	let getTracksAction: Action<Int, ([Track],[Channel])>!
	let disposeBag = DisposeBag()
        
    init(channelID: Int)
    {
        getTracksAction = Action<Int, ([Track],[Channel])>.init(workFactory: { (offset) -> Observable<([Track],[Channel])> in
            return RequestManager.shared.tracks(req: TracksRequest.channel(channelID))
        })
        
        getTracksAction.elements
            .map({ (tuple) -> [TrackViewModel] in
                let playingId = AudioController.main.currentTrack?.id
                return tuple.0.map({ (track) -> TrackViewModel in
                    var vm = TrackViewModel(track: track,
                                            isPlaying: track.id == playingId)
//                    if let channel = tuple.1.filter({$0.id == track.channelId}).first {
                    if let _ = self.channel
                    {
                        vm.authorImage = self.channel.image
                        vm.author = self.channel.name
                    }
                    return vm
                })
            }).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
                self.delegate?.reload(tracks: vms)
            }, onCompleted: {
                print("Track loaded")
            }).disposed(by: self.disposeBag)

        RequestManager.shared.channel(id: channelID).subscribe(onNext: { (channel) in
            self.channel = channel
        }).disposed(by: disposeBag)
        
        InAppUpdateManager.shared.subscribe(self)
		
		self.getData()
    }
    
    func getData() {
        self.getTracksAction.execute(0)
    }
    
    deinit {
    }
    
    func set(channel: Channel) {
        self.channel = channel
        
        let channels: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
        self.delegate?.getChannel(channel: FullChannelViewModel.init(channel: channel))
    }
    
    func followPressed() {
        // to server
        let action: ChannelAction = channel.isSubscribed ? ChannelAction.unsubscribe : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        // while in User Setting
        subManager.addOrDelete(channel: self.channel.id)
        channel.isSubscribed = !channel.isSubscribed
        self.delegate?.followUpdate(isSubscribed: channel.isSubscribed)
    }
    
    func getTrackViewModels()
    {
        var trackVMs = [TrackViewModel]()
        for track in self.tracks
        {
            trackVMs.append(TrackViewModel.init(track: track, isPlaying: false))
        }
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.delegate?.getChannel(channel: FullChannelViewModel(channel: self.channel))
        case .appear:
            break
        default:
            break
        }
    }
}

extension ChannelModel: SettingsUpdateProtocol, PlayingStateUpdateProtocol, SubscriptionUpdateProtocol, TrackUpdateProtocol {
    func settingsUpdated() {
        
    }
    
    func trackPlayingUpdate(id: Int, isPlaying: Bool) {
        if isPlaying {
            if let index = self.tracks.index(where: {$0.id == id}) {
                self.playingIndex.value = index
            }
        } else {
            self.playingIndex.value = nil
        }
    }
    
    func channelSubscriptionUpdated() {
        let channels: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
        channel.isSubscribed = channels.contains(channel.id)
        
        self.delegate?.followUpdate(isSubscribed: channel.isSubscribed)
    }
    
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.delegate?.trackUpdate(index: index, vm: vm)
        }
    }
}
