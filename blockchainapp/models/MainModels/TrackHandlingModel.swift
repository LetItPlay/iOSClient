//
//  TrackHandlingModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 17.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import Action
import RxSwift

protocol TrackHandlingModelDelegate: class {
    func update(tracks: [Int: TrackViewModel], length: String)
    func show(tracks: [TrackViewModel], isContinue: Bool, length: String)
    func empty(show: Bool)
    func noDataLeft()
    func showChannel(id: Int)
    func showInfo(track: ShareInfo)
}

class TrackHandlingModel {
    private var currentOffest: Int = 0
    private let amount: Int = 100
    
    var playlistName: String = LocalizedStrings.TabBar.feed
    var tracks: [Track] = []
    
    weak var delegate: TrackHandlingModelDelegate?
    
    private var dataAction: Action<Int, [Track]>?
    private let disposeBag = DisposeBag()
    
    init(name: String, dataAction: Action<Int, [Track]>) {
        
        self.dataAction = dataAction
        self.playlistName = name
        
        self.dataAction?.elements.do(onNext: { (tracks) in
            if self.currentOffest == 0 {
                self.tracks = tracks
            } else {
                self.tracks += tracks
            }
        }).map({ (tracks) -> [TrackViewModel] in
            let playingId = PlayerHandler.player?.playingNow
            return tracks.map({ TrackViewModel(track: $0,
                                               isPlaying: $0.id == playingId) })
        }).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
            self.delegate?.show(tracks: vms, isContinue: self.currentOffest != 0, length: self.tracksLength())
            self.delegate?.empty(show: self.tracks.count == 0)
            self.currentOffest = self.tracks.count
        }, onCompleted: {
            print("Track loaded")
        }).disposed(by: self.disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.dataAction?.execute(0)
        case .appear:
            break
        case .disappear:
            break
        case .deinitialize:
            break
        }
    }
    
    func tracksLength() -> String {
        var length: Int64 = 0
        for track in tracks {
            length += track.length
        }
        return length.formatTime()
    }
}


extension TrackHandlingModel: PlayingStateUpdateProtocol, TrackUpdateProtocol, SettingsUpdateProtocol {
    func trackPlayingUpdate(dict: [Int : Bool]) {
        var res: [Int: TrackViewModel] = [:]
        for tuple in dict {
            if let index = self.tracks.index(where: {tuple.key == $0.id}) {
                res[index] = TrackViewModel.init(track: self.tracks[index], isPlaying: tuple.value)
            }
        }
        self.delegate?.update(tracks: res, length: self.tracksLength())
    }
    
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.tracks[index] = track
            self.delegate?.update(tracks: [index : vm], length: self.tracksLength())
        }
    }
    
    func settingsUpdated() {
        self.reload()
    }
}

extension TrackHandlingModel: TrackEventHandler {
    func trackLiked(index: Int) {
        ServerUpdateManager.shared.make(track: self.tracks[index], action: .like)
    }
    
    func reload() {
        self.currentOffest = 0
        self.dataAction?.execute(0)
    }
    
    func trackShowed(index: Int) {
        if index > self.tracks.count - self.amount/10 {
            self.dataAction?.execute(self.tracks.count)
        }
    }
    
    func addTrack(index: Int, toBegining: Bool) {
        UserPlaylistManager.shared.add(track: self.tracks[index], toBegining: toBegining)
    }
    
    func showChannel(index: Int) {
        self.delegate?.showChannel(id: self.tracks[index].channel.id)
    }
    
    func showOthers(index: Int) {
        let track = self.tracks[index]
        self.delegate?.showInfo(track: track.sharedInfo())
    }
}

protocol TrackEventHandler: class, PlayerUsingProtocol {
    func reload()
    func trackLiked(index: Int)
    func trackShowed(index: Int)
    func showChannel(index: Int)
    func showOthers(index: Int)
    func addTrack(index: Int, toBegining: Bool)
}
