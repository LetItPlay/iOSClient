//
//  SearchModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

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
    
    var tracks: [Track] = []
    var channels: [Station] = []
    
    var currentPlayingIndex: Int = -1
    var currentSearchString: String = ""
    
    let realm: Realm? = try? Realm()
    
    var delegate: SearchModelDelegate?
    
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
        self.currentSearchString = string
        if string.count == 0 {
            self.tracks = []
            self.channels = []
        } else {
//            self.tracks = self.realm?.objects(Track.self).filter("name contains[cd] '\(string.lowercased())' OR ANY tags.value CONTAINS[cd] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
//            self.channels = self.realm?.objects(Station.self).filter("name contains[cd] '\(string.lowercased())' OR ANY tags.value CONTAINS[cd] '\(string.lowercased())'").filter({$0.lang == UserSettings.language.rawValue}).map({$0}) ?? []
        }
        self.get(viewModels: .all)
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
