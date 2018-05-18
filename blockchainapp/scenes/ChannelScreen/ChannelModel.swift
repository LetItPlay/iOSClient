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
        
    init(channelID: Int, name: String, dataAction: Action<Int, [Track]>) {
        super.init(name: name, dataAction: dataAction)

        RequestManager.shared.channel(id: channelID).subscribe(onNext: { (channel) in
            self.channel = channel
			self.playlistName = LocalizedStrings.Channels.channel + " \(channel.name)"
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
            self.channelDelegate?.getChannel(channel: FullChannelViewModel(channel: self.channel))
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

