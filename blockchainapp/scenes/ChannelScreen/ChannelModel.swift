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

protocol ChannelModelProtocol: class, ModelProtocol {
    weak var delegate: ChannelModelDelegate? {get set}
}

protocol ChannelEvenHandler: class {
    func followPressed()
}

protocol ChannelModelDelegate: class {
    func reload(tracks: [TrackViewModel])
    func trackUpdate(index: Int, vm: TrackViewModel)
    func followUpdate(isSubscribed: Bool)
}

class ChannelModel: ChannelModelProtocol, ChannelEvenHandler {
    
    var delegate: ChannelModelDelegate?
    
    var tracks: [Track] = []
    var token: NotificationToken?
    var channel: Station!
    var currentTrackID: Int?
    
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    var subManager = SubscribeManager.shared
    
    init(channelID: Int)
    {
        let realm = try! Realm()
        let stationResults = realm.objects(Station.self).filter("id == \(channelID)")
        self.channel = stationResults[0]
        
        let results = realm.objects(Track.self).filter("station == \(channel.id)").sorted(byKeyPath: "publishedAt", ascending: false)
        token = results.observe({ [weak self] (changes: RealmCollectionChange) in
            let filter: (Track) -> Bool = {$0.station == self?.channel.id}
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
//                self?.tracks = [Array(results)]
                break
            case .update(_, _, _, _):
                // Query results have changed, so apply them to the UITableView
//                self?.tracks = [Array(results).filter(filter)]
                break
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
            self?.getTrackViewModels()
        })

        InAppUpdateManager.shared.subscribe(self)
        
        self.getData()
    }
    
    func getData() {
        DownloadManager.shared.requestTracks(all: true, success: { (feed) in
            
        }) { (err) in
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
    
    func followPressed() {
        subManager.addOrDelete(station: self.channel.id)
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
    
    func stationSubscriptionUpdated() {
        
    }
    
    func trackUpdated(track: Track1) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.delegate?.trackUpdate(index: index, vm: vm)
        }
    }
}
