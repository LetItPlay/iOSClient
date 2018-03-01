//
//  SearchModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum ViewModels {
    case channels, tracks
}

protocol SearchModelProtocol: class, ModelProtocol {
    weak var delegate: SearchModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol SearchEventHandler: class {
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int)
    func channelSubscriptionPressedAt(index: Int)
    func searchChanged(string: String)
}

protocol SearchModelDelegate: class {
    func update(tracks: [TrackViewModel])
    func update(channels: [SearchChannelViewModel])
    func update(index: Int, vm: SearchChannelViewModel)
    func update(index: Int, vm: TrackViewModel)
    func showChannel(id: Int)
}

class SearchModel: SearchModelProtocol, SearchEventHandler {
    
    var tracks: [Track] = []
    var channels: [Channel] = []
    var searchTracks: [Track] = []
    var searchChannels: [Channel] = []
	
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    var currentSearchString: String = ""
    
    let realm: Realm? = try? Realm()
    
    var delegate: SearchModelDelegate?
    
    let disposeBag = DisposeBag()
    
    init()
    {
		Observable<([Track], [Channel])>.combineLatest(RequestManager.shared.tracks(req: .allTracks), RequestManager.shared.channels()) { (tracksTuple, channels) -> ([Track], [Channel]) in
			return (tracksTuple.0, channels)
			}.subscribe(onNext: {(tuple) in
				self.tracks = tuple.0
				self.channels = tuple.1
				self.searchChanged(string: self.currentSearchString)
			}).disposed(by: self.disposeBag)
        
        InAppUpdateManager.shared.subscribe(self)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.delegate?.update(tracks: self.searchTracks.map({TrackViewModel.init(track: $0)}))
            self.delegate?.update(channels: self.searchChannels.map({SearchChannelViewModel(channel: $0)}))
        default:
            break
        }
    }
    func searchChanged(string: String) {
        self.playingIndex.value = nil
        self.currentSearchString = string.lowercased()
        if string.count == 0 {
            self.searchChannels = []
            self.searchTracks = []
            
            self.delegate?.update(tracks: self.searchTracks.map({TrackViewModel.init(track: $0)}))
            self.delegate?.update(channels: self.searchChannels.map({SearchChannelViewModel(channel: $0)}))
        } else {
            
            self.searchTracks = self.tracks.filter({ track in
                if track.name.lowercased().range(of: self.currentSearchString) != nil
                {
                    return true
                }
                
                if track.tags.count != 0 {
                    for tag in track.tags
                    {
                        if tag.lowercased().range(of: self.currentSearchString) != nil
                        {
                            return true
                        }
                    }
                }
                else
                {
                    for tag in (channels.filter({$0.id == track.channelId}).first?.tags)!
                    {
                        if tag.lowercased().range(of: self.currentSearchString) != nil
                        {
                            return true
                        }
                    }
                }
                
                return false
            })
            
            var trackPlayingIndex: Int = -1
            self.delegate?.update(tracks: self.searchTracks.map({ (track) -> TrackViewModel in
                var vm = TrackViewModel(track: track)
                
                if track.id == AudioController.main.currentTrack?.id
                {
                    vm.isPlaying = true
                    trackPlayingIndex = self.searchTracks.index(where: {$0.id == track.id})!
                }
                
                if let channel = self.channels.first(where: {$0.id == track.channelId}) {
                    vm.author = channel.name
                    vm.authorImage = channel.image
                }
                return vm
            }))
            self.playingIndex.value = trackPlayingIndex
            
            self.searchChannels = self.channels.filter({ channel in
                if channel.name.lowercased().range(of: self.currentSearchString) != nil
                {
                    return true
                }
                
                for tag in channel.tags
                {
                    if tag.contains(self.currentSearchString)
                    {
                        return true
                    }
                }
                return false
            })
            self.delegate?.update(channels: self.searchChannels.map({SearchChannelViewModel(channel: $0)}))
        }
    }
    
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int) {
        switch viewModels {
        case .channels:
            AnalyticsEngine.sendEvent(event: .searchEvent(event: .channelTapped))
            self.delegate?.showChannel(id: self.searchChannels.count != 0 ? self.searchChannels[atIndex].id : self.channels[atIndex].id)
        case .tracks:
            AnalyticsEngine.sendEvent(event: .searchEvent(event: .trackTapped))
            self.trackSelected(index: atIndex)
        }
    }
    
    func trackSelected(index: Int) {
        let tracks = self.searchTracks.map { (track) -> AudioTrack in
            return track.audioTrack(author: self.channels.first(where: {$0.id == track.channelId})?.name ?? "")
        }
        AudioController.main.loadPlaylist(playlist: ("Search".localized, tracks), playId: self.searchTracks[index].id)
    }
    
    func channelSubscriptionPressedAt(index: Int) {
        let channel = self.searchChannels.count != 0 ? self.searchChannels[index] : self.channels[index]
        let action: ChannelAction = channel.isSubscribed ? ChannelAction.unsubscribe : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        
        // while in User Settings
        SubscribeManager.shared.addOrDelete(channel: channel.id)
    }
}

extension SearchModel: SettingsUpdateProtocol, ChannelUpdateProtocol, PlayingStateUpdateProtocol {
    func trackPlayingUpdate(id: Int, isPlaying: Bool) {
        if isPlaying {
            if let index = self.searchTracks.index(where: {$0.id == id})
            {
                self.playingIndex.value = index
            }
        } else {
            self.playingIndex.value = nil
        }
    }
    
    func settingsUpdated() {
        
    }
    
    func channelUpdated(channel: Channel) {
        if let index = self.channels.index(where: {$0.id == channel.id}) {
            self.channels[index] = channel
            var oldChannel = channel
            oldChannel.isSubscribed = !oldChannel.isSubscribed
            var searchIndex = index

            if self.searchChannels.count != 0
            {
                if let someIndex: Int = self.searchChannels.index(of: oldChannel)
                {
                    searchIndex = someIndex
                    self.searchChannels[searchIndex] = channel
                }
            }

            self.delegate?.update(index: searchIndex, vm: SearchChannelViewModel(channel: channel))
        }
    }
}
