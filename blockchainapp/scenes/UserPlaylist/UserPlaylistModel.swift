
//
//  UserPlaylistModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol UserPlaylistModelProtocol: class, ModelProtocol {
    weak var delegate: UserPlaylistModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol UserPlaylistEventHandler: class {
    func trackSelected(index: Int)
    func clearPlaylist()
}

protocol UserPlaylistModelDelegate: class {
    func show(tracks: [TrackViewModel])
    func emptyMessage(show: Bool)
}

class UserPlaylistModel: UserPlaylistModelProtocol, UserPlaylistEventHandler
{
    var delegate: UserPlaylistModelDelegate?
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    private var tracks: [Track] = []
    
    init()
    {
        
        InAppUpdateManager.shared.subscribe(self)
    }
    
    func reload()
    {
        self.tracks = UserPlaylistManager.shared.tracks
        
        self.delegate?.emptyMessage(show: self.tracks.count == 0 ? true : false)
        self.delegate?.show(tracks: self.tracks.map({TrackViewModel(track: $0)}))
    }
    
    func trackSelected(index: Int) {
        let tracks = self.tracks.map { (track) -> AudioTrack in
            return track.audioTrack(author: "")
//            return track.audioTrack(author: channels.first(where: {$0.id == track.channelId})?.name ?? "")
        }
        AudioController.main.loadPlaylist(playlist: ("My playlist".localized, tracks), playId: self.tracks[index].id)
    }
    
    func clearPlaylist() {
        UserPlaylistManager.shared.tracks.removeAll()
        self.delegate?.emptyMessage(show: true)
        self.tracks = UserPlaylistManager.shared.tracks
        self.delegate?.show(tracks: self.tracks.map({TrackViewModel(track: $0)}))
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        case .appear:
            self.reload()
        default:
            break
        }
    }
}

extension UserPlaylistModel: PlayingStateUpdateProtocol
{
    func trackPlayingUpdate(id: Int, isPlaying: Bool) {
        if isPlaying {
            if let index = self.tracks.index(where: {$0.id == id}) {
                self.playingIndex.value = index
            }
        } else {
            self.playingIndex.value = nil
        }
    }
}
