//
//  LikesModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol LikesModelProtocol: class, ModelProtocol {
    func getTracks()
    func selectedTrack(index: Int)
}

protocol LikesModelDelegate: class {
    func reload(tracks: [TrackViewModel], length: String)
    func update(track: TrackViewModel, atIndex: Int)
}

class LikesModel: LikesModelProtocol {

    weak var delegate: LikesModelDelegate?
    private var token: NotificationToken?
    
    private var tracks: [Track] = []
    private var playingIndex: Int = -1
    
    private let disposeBag = DisposeBag()
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPlayed(notification:)),
                                               name: AudioController.AudioStateNotification.playing.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPaused(notification:)),
                                               name: AudioController.AudioStateNotification.paused.notification(),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
    
    @objc func trackPlayed(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
            if self.playingIndex != -1
            {
                self.delegate?.update(track: TrackViewModel.init(track: self.tracks[playingIndex], isPlaying: false, isLiked: true), atIndex: playingIndex)
            }
            
            self.playingIndex = index
            self.delegate?.update(track: TrackViewModel.init(track: self.tracks[index], isPlaying: true, isLiked: true), atIndex: playingIndex)
        }
    }
    
    @objc func trackPaused(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
            self.delegate?.update(track: TrackViewModel.init(track: self.tracks[index], isPlaying: false, isLiked: true), atIndex: playingIndex)
        }
    }
    
    func getTracks() {
        let realm = try? Realm()
        let likeMan = LikeManager.shared
        self.tracks = realm?.objects(Track.self).map({$0.detached()}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue}) ?? []
        
        self.getTracksViewModel()
    }
    
    func selectedTrack(index: Int) {
        let contr = AudioController.main
        contr.loadPlaylist(playlist: ("Liked".localized, self.tracks.map({$0.audioTrack()})), playId: self.tracks[index].id)
    }
    
    func getTracksViewModel()
    {
        var length: Int64 = 0
        var tracksVMs = [TrackViewModel]()
        for i in 0..<tracks.count
        {
            tracksVMs.append(TrackViewModel.init(track: tracks[i], isPlaying: i == playingIndex ? true : false, isLiked: true))
            length += tracks[i].length
        }
        
        self.delegate?.reload(tracks: tracksVMs, length: length.formatTime())
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        case .appear:
            self.getTracks()
        default:
            break
        }
    }
    
}
