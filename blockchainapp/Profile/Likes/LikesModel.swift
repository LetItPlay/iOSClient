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

protocol LikesModelProtocol {
    func getTracks()
}

protocol LikesModelDelegate: class {
    func reload(tracks: [TrackViewModel])
}

class LikesModel: LikesModelProtocol {
    
    weak var delegate: LikesModelDelegate?
    private var token: NotificationToken?
    
    private var tracks: [Track] = []
    private var playingIndex: Int? = nil
    
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
            self.playingIndex = index
        }
    }
    
    @objc func trackPaused(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
            self.playingIndex = -1
        }
    }
    
    func getTracks() {
        let realm = try? Realm()
        let likeMan = LikeManager.shared
        self.tracks = realm?.objects(Track.self).map({$0.detached()}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue}) ?? []
        
        self.getTracksViewModel()
    }
    
    func getTracksViewModel()
    {
        var tracksVMs = [TrackViewModel]()
        for i in 0..<tracks.count
        {
            tracksVMs.append(TrackViewModel.init(track: tracks[i], isPlaying: i == playingIndex ? true : false, isLiked: true))
        }
        
        self.delegate?.reload(tracks: tracksVMs)
    }
}
