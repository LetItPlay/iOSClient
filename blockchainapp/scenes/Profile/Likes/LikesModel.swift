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
    func trackUpdate(index: Int, vm: TrackViewModel)
}

class LikesModel: LikesModelProtocol {

    weak var delegate: LikesModelDelegate?
    private var token: NotificationToken?
    
    private var tracks: [TrackObject] = []
    private var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    private let disposeBag = DisposeBag()
    
    init() {
        InAppUpdateManager.shared.subscribe(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
    
    func getTracks() {
        let realm = try? Realm()
        let likeMan = LikeManager.shared
        self.tracks = realm?.objects(TrackObject.self).map({$0.detached()}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue}) ?? []
        
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
            tracksVMs.append(TrackViewModel.init(track: tracks[i], isPlaying: i == playingIndex.value ? true : false, isLiked: true))
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

extension LikesModel: PlayingStateUpdateProtocol, TrackUpdateProtocol, SettingsUpdateProtocol {
    func settingsUpdated() {
        self.getTracks()
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
    
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.delegate?.trackUpdate(index: index, vm: vm)
        }
    }
}
