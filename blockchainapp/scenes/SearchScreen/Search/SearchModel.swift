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
}

protocol SearchEventHandler: class {
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int)
    func channelSubPressedAt(index: Int)
    func searchChanged(string: String)
}

protocol SearchModelDelegate: class {
    func update(tracks: [TrackViewModel])
    func update(channels: [SearchChannelViewModel])
//    func update(tracks: [TrackViewModel], channels: [SearchChannelViewModel])
}

class SearchModel: SearchModelProtocol, SearchEventHandler {
    
    var tracks: [Track] = []
    var channels: [Channel] = []
    var searchTracks: [Track] = []
    var searchChannels: [Channel] = []
	
    var currentPlayingIndex: Int = -1
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
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.update(viewModels: self.tracks)
            self.update(viewModels: self.channels)
        default:
            break
        }
    }
    func searchChanged(string: String) {
        self.currentSearchString = string.lowercased()
        if string.count == 0 {
            self.searchChannels = []
            self.searchTracks = []
        } else {
            
            self.searchTracks = self.tracks.filter({ track in
                if track.name.lowercased().range(of: self.currentSearchString) != nil
                {
                    return true
                }
                
                for tag in track.tags
                {
                    if tag.lowercased().range(of: self.currentSearchString) != nil
                    {
                        return true
                    }
                }
                return false
            })
            self.update(viewModels: self.searchTracks)
            
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
            self.update(viewModels: self.searchChannels)
        }
    }
    
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int) {
        // to router
    }
    
    func channelSubPressedAt(index: Int) {
        let channel = self.searchChannels[index]
        SubscribeManager.shared.addOrDelete(channel: channel.id)
        self.update(viewModels: self.searchChannels)
    }
    
    func update(viewModels: [Any])
    {
        if viewModels is [Channel]
        {
            self.delegate?.update(channels: self.getChannelVMs(for: viewModels as! [Channel]))
        }
        else
        {
            self.delegate?.update(tracks: self.getTrackVMs(for: viewModels as! [Track]))
        }
    }
    
    func getTrackVMs(for tracks: [Track]) -> [TrackViewModel] {
        var trackVMs = [TrackViewModel]()
        for track in tracks
        {
			var vm = TrackViewModel.init(track: track, isPlaying: false)
			if let channel = self.channels.first(where: {$0.id == track.channelId}) {
				vm.author = channel.name
				vm.authorImage = channel.image
			}
            trackVMs.append(vm)
        }
        return trackVMs
    }
    
    func getChannelVMs(for channels: [Channel]) -> [SearchChannelViewModel]
    {
        let channelsId: [Int] = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
        
        var channelVMs: [SearchChannelViewModel] = []
        for channel in channels
        {
            channelVMs.append(SearchChannelViewModel.init(channel: channel, isSubscribed: channelsId.contains(channel.id)))
        }
        return channelVMs
    }
}
