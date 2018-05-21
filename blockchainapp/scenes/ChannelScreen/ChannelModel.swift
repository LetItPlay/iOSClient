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
    var channelDelegate: ChannelModelDelegate? {get set}
}

protocol ChannelEvenHandler: class {
    func followPressed()
    func showSearch(text: String?)
    func selected(tag: String)
    func showOthers()
}

protocol ChannelModelDelegate: class {
    func getChannel(channel: FullChannelViewModel)
    func showSearch(text: String?)
    func showOthers(shareInfo: ShareInfo)
}

class ChannelModel: TrackHandlingModel, ChannelModelProtocol, ChannelEvenHandler {
	
    weak var channelDelegate: ChannelModelDelegate?
    
    var channel: Channel!
	let disposeBag = DisposeBag()
    
    private var getChannelAction: Action<Int, Channel>?
        
    init(channelID: Int) {
        
        let name = LocalizedStrings.Channels.channel + " \(channelID)"
        let dataAction = Action<Int, [Track]>.init(workFactory: { (offset) -> Observable<[Track]> in
            return RequestManager.shared.tracks(req: TracksRequest.channel(channelID))
        })
        
        super.init(name: name, dataAction: dataAction)
        
        self.getChannelAction = Action<Int, Channel>.init(workFactory: { (_) -> Observable<Channel> in
            return RequestManager.shared.channel(id: channelID)
        })
        
        self.getChannelAction?.elements.do(onNext: { (channel) in
            self.channel = channel
        }).subscribeOn(MainScheduler.instance).subscribe(onNext: { (channel) in
            self.playlistName = LocalizedStrings.Channels.channel + " \(channel.name)"
            self.channelDelegate?.getChannel(channel: FullChannelViewModel(channel: self.channel))
        }, onCompleted: {
            print("Channel loaded")
        }).disposed(by: disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func followPressed() {
        let action: ChannelAction = self.channel.isHidden ? ChannelAction.showHidden : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
    }
    
    func selected(tag: String) {
        self.showSearch(text: tag)
    }
    
    func showSearch(text: String?) {
        self.channelDelegate?.showSearch(text: text)
    }
    
    func showOthers() {
        self.channelDelegate?.showOthers(shareInfo: self.channel.sharedInfo())
    }
    
    override func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.getChannelAction?.execute(0)
        default:
            break
        }
        
        super.send(event: event)
    }
}

extension ChannelModel: ChannelUpdateProtocol {
    
    func channelUpdated(channel: Channel) {
        if let _ = self.channel {
            if self.channel.id == channel.id {
                self.channel = channel
                self.channelDelegate?.getChannel(channel: FullChannelViewModel(channel: self.channel))
            }
        }
    }
}

