//
//  ChannelVCModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChannelVCModelProtocol {
    func getTracks()
}

protocol ChannelVCModelDelegate {
    func reload(tracks: [TrackViewModel])
    func update(index: Int, track: TrackViewModel)
    func followUpdate(isSubscribed: Bool)
}

class ChannelVCModel: ChannelVCModelProtocol {
    
    var delegate: ChannelVCModelDelegate?
    
    var tracks: [Track] = []
    var token: NotificationToken?
    var channel: Station!
    var currentTrackID: Int?
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPlayed(notification:)),
                                               name: AudioController.AudioStateNotification.playing.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPaused(notification:)),
                                               name: AudioController.AudioStateNotification.paused.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subscribed(notification:)),
                                               name: SubscribeManager.NotificationName.added.notification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unsubscribed(notification:)),
                                               name: SubscribeManager.NotificationName.deleted.notification,
                                               object: nil)
        
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
    
    @objc func trackPlayed(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
            if let curr = self.currentTrackID {
                let newVM = TrackViewModel(track: tracks[curr], isPlaying: false)
                self.delegate?.update(index: curr, track: newVM)
            }
            let newVM = TrackViewModel(track: tracks[index], isPlaying: false)
            self.delegate?.update(index: index, track: newVM)
            //            var reload = [Int]()
            //            if playingIndex != -1 {
            //                reload.append(playingIndex)
            //            }
            //            reload.append(index)
            //            self.playingIndex = index
            //            self.view?.reload(update: reload, delete: [], insert: [])
        }
    }
    
    @objc func trackPaused(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
            //            var reload = [Int]()
            //            if playingIndex != -1 {
            //                reload.append(playingIndex)
            //            }
            //            self.playingIndex = -1
            //            self.view?.reload(update: reload, delete: [], insert: [])
        }
    }
    
    @objc func subscribed(notification: Notification) {
        self.delegate?.followUpdate(isSubscribed: true)
    }
    
    @objc func unsubscribed(notification: Notification) {
        self.delegate?.followUpdate(isSubscribed: false)
    }
    
    func getTrackViewModels()
    {
        var trackVMs = [TrackViewModel]()
        for track in self.tracks
        {
            trackVMs.append(TrackViewModel.init(track: track, isPlaying: false))
        }
    }
    
    func getTracks() {
        
    }
}
