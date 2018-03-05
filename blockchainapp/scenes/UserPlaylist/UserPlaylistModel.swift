
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
}

protocol UserPlaylistModelDelegate: class {
//    func show(tracks: [TrackViewModel])
}

class UserPlaylistModel: UserPlaylistModelProtocol, UserPlaylistEventHandler
{
    var delegate: UserPlaylistModelDelegate?
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    private var tracks: [PlayerTrack] = []
    
    init()
    {
        
        InAppUpdateManager.shared.subscribe(self)
    }
    
    func reload()
    {
        self.tracks = UserPlaylistManager.shared.tracks
    }
    
    func trackSelected(index: Int) {
        let track = self.tracks[index]
        AudioController.main.loadPlaylist(playlist: ("Playlist".localized, self.tracks), playId: track.id)
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
