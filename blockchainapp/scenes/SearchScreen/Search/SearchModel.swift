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
    case channels, tracks, all
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
    func update(tracks: [TrackViewModel], channels: [SearchChannelViewModel])
}

class SearchModel: SearchModelProtocol, SearchEventHandler {
    
    var tracks: [Track1] = []
    var channels: [Station1] = []
    
    var currentPlayingIndex: Int = -1
    var currentSearchString: String = ""
    
    let realm: Realm? = try? Realm()
    
    var delegate: SearchModelDelegate?
    
    let disposeBag = DisposeBag()
    
    init()
    {
        
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
    
    func searchChanged(string: String) {
        self.currentSearchString = string.lowercased()
        if string.count == 0 {
            self.tracks = []
            self.channels = []
        } else {
            RequestManager.shared.tracks(req: .allTracks).subscribe(onNext: {(tuple) in
                self.tracks = tuple.0.filter({ track in
                    if track.name.lowercased().range(of: self.currentSearchString) != nil
                    {
                        return true
                    }
                    
                    return false
                })
                self.get(viewModels: .tracks)
            }).disposed(by: self.disposeBag)
            
            RequestManager.shared.channels().subscribe(onNext: { (stations) in
                self.channels = stations.filter({ channel in
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
                self.get(viewModels: .channels)
            }).disposed(by: self.disposeBag)
        }
    }
    
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int) {
        // to connector
    }
    
    func channelSubPressedAt(index: Int) {
        
    }
    
    func get(viewModels: ViewModels)
    {
        switch viewModels {
        case .channels:
            self.delegate?.update(channels: self.getChannelVMs())
        case .tracks:
            self.delegate?.update(tracks: self.getTrackVMs())
        case .all:
            self.delegate?.update(tracks: self.getTrackVMs(), channels: self.getChannelVMs())
        }
    }
    
    func getTrackVMs() -> [TrackViewModel] {
        var trackVMs = [TrackViewModel]()
        for track in self.tracks
        {
            trackVMs.append(TrackViewModel.init(track: track, isPlaying: false))
        }
        return trackVMs
    }
    
    func getChannelVMs() -> [SearchChannelViewModel]
    {
        var channelVMs: [SearchChannelViewModel] = []
        for channel in self.channels
        {
            channelVMs.append(SearchChannelViewModel.init(channel: channel))
        }
        return channelVMs
    }
}
