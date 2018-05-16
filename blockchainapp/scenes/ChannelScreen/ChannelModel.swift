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
                let _ = player.trackSelected(playlistName: self.playlistName, id: selectedId)
            }
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
    func showSearch(text: String?)
    func showOthers(index: Int)
    func showOthers()
    func selected(tag: String)
}

protocol ChannelModelDelegate: class {
    func reload(tracks: [TrackViewModel])
    func trackUpdate(dict: [Int: TrackViewModel])
    func getChannel(channel: FullChannelViewModel)
    func followUpdate(isSubscribed: Bool)
    func showSearch(text: String?)
    func showOthers(shareInfo: ShareInfo)
}

class ChannelModel: ChannelModelProtocol, ChannelEvenHandler, PlayerUsingProtocol {
	
	var playlistName: String = "Channel".localized
    weak var delegate: ChannelModelDelegate?
    
    var tracks: [Track] = []
    var channel: Channel!
    var currentTrackID: Int?
    
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    	
	let getTracksAction: Action<Int, [Track]>!
	let disposeBag = DisposeBag()
        
    init(channelID: Int, playTrack: Int? = nil)
    {
		self.playlistName = "Channel".localized + " \(channelID)"
        
        if let id = playTrack {
            self.currentTrackID = id
        }
		
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
                if let _ = self.currentTrackID, let index = self.tracks.index(where: {$0.id == self.currentTrackID}) {
                    PlayerHandler.playlist?.clearAll(direction: .down)
                    self.trackSelected(index: index)
                }
            }, onCompleted: {
                print("Track loaded")
            }).disposed(by: self.disposeBag)

        RequestManager.shared.channel(id: channelID).subscribe(onNext: { (channel) in
            self.channel = channel
			self.playlistName = "Channel".localized + " \(channel.name)"
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
        let action: ChannelAction = self.channel.isHidden ? ChannelAction.showHidden : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
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
    
    func selected(tag: String) {
        self.showSearch(text: tag)
    }
    
    func showSearch(text: String?) {
        self.delegate?.showSearch(text: text)
    }
    
    func showOthers(index: Int) {
        let track = self.tracks[index]
        self.delegate?.showOthers(shareInfo: track.sharedInfo())
    }
    
    func showOthers() {
        self.delegate?.showOthers(shareInfo: self.channel.sharedInfo())
    }
}

extension ChannelModel: SettingsUpdateProtocol, PlayingStateUpdateProtocol, TrackUpdateProtocol, ChannelUpdateProtocol {

    func settingsUpdated() {
        
    }
    
    func trackPlayingUpdate(dict: [Int : Bool]) {
        self.delegate?.trackUpdate(dict: self.transform(tracks: self.tracks, dict: dict))
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
    
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.delegate?.trackUpdate(dict: [index: vm])
        }
    }
    
    func channelUpdated(channel: Channel) {
        if let _ = self.channel {
            if self.channel.id == channel.id {
                self.channel = channel
                self.delegate?.getChannel(channel: FullChannelViewModel(channel: self.channel))
            }
        }
    }
}

