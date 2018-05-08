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

protocol PlayerUsingProtocol {
	var tracks: [Track] {get}
	var playlistName: String {get}
	func trackSelected(index: Int)
}

extension PlayerUsingProtocol {
	func trackSelected(index: Int) {
		let selectedId = self.tracks[index].id
		if let player = PlayerHandler.player {
			if !player.trackSelected(playlistName: self.playlistName, id: selectedId) {
				player.loadPlaylist(name: self.playlistName, tracks: self.tracks)
			}
			let _ = player.trackSelected(playlistName: self.playlistName, id: selectedId)
		}
	}
}

protocol ChannelModelProtocol: ModelProtocol {
    var delegate: ChannelModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol ChannelEvenHandler: class {
	func trackSelected(index: Int)
    func followPressed()
    func set(channel: Channel)
    func showSearch()
    func showOthers(index: Int)
    func shareChannel()
}

protocol ChannelModelDelegate: class {
    func reload(tracks: [TrackViewModel])
    func trackUpdate(index: Int, vm: TrackViewModel)
    func getChannel(channel: FullChannelViewModel)
    func followUpdate(isSubscribed: Bool)
    func showSearch()
    func showOthers(track: Track)
    func share(channel: ShareInfo)
}

class ChannelModel: ChannelModelProtocol, ChannelEvenHandler, PlayerUsingProtocol {
	
	var playlistName: String = "Channel".localized
    weak var delegate: ChannelModelDelegate?
    
    var tracks: [Track] = []
    var channel: Channel!
    var currentTrackID: Int?
    
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    var subManager = SubscribeManager.shared
	
	let getTracksAction: Action<Int, [Track]>!
	let disposeBag = DisposeBag()
        
    init(channelID: Int)
    {
		self.playlistName = "Channel".localized + " \(channelID)"
		
        getTracksAction = Action<Int, [Track]>.init(workFactory: { (offset) -> Observable<[Track]> in
            return RequestManager.shared.tracks(req: TracksRequest.channel(channelID))
        })
        
        getTracksAction.elements.do(onNext: { (tracks) in
            self.tracks = tracks
        }).map({ (tracks) -> [TrackViewModel] in
                let playingId = PlayerHandler.player?.playingNow
                return tracks.map({ return TrackViewModel(track: $0, isPlaying: $0.id == playingId)})
            }).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
                self.delegate?.reload(tracks: vms)
            }, onCompleted: {
                print("Track loaded")
            }).disposed(by: self.disposeBag)

        RequestManager.shared.channel(id: channelID).subscribe(onNext: { (channel) in
            self.channel = channel
			self.playlistName = "Channel".localized + " \(channel.name)"
            let subscriptions = self.subManager.channels
            self.channel.isSubscribed = subscriptions.contains(channel.id)
            self.delegate?.getChannel(channel: FullChannelViewModel(channel: self.channel))
//            self.delegate?.followUpdate(isSubscribed: self.channel.isSubscribed)
        }).disposed(by: disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
		
		self.getData()
    }
    
    func getData() {
        self.getTracksAction.execute(0)
    }
    
    deinit {
    }
    
    func set(channel: Channel) {
        self.channel = channel
        
        self.delegate?.getChannel(channel: FullChannelViewModel.init(channel: channel))
    }
    
    func followPressed() {
        // to server
        let action: ChannelAction = ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        // while in User Setting
        subManager.addOrDelete(channel: self.channel.id)
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
    
    func showSearch() {
        self.delegate?.showSearch()
    }
    
    func showOthers(index: Int) {
        self.delegate?.showOthers(track: self.tracks[index])
    }
    
    func shareChannel() {
        self.delegate?.share(channel: ShareInfo(text: self.channel.name, url: RequestManager.server + "/channels/\(channel.id)", image: try! UIImage(data: Data(contentsOf: (channel.image)!))!))
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

