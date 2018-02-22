//
//  PlaylistsModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol PlaylistsModelProtocol: ModelProtocol {
    weak var delegate: PlaylistsModelDelegate? {get set}
}

protocol PlaylistsEventHandler: class {
    func formatPlaylists(index: Int)
    func refresh()
}

protocol PlaylistsModelDelegate: class {
    func update(playlists: [PlaylistViewModel])
    func update(tracks: [Int], channels: [Int])
}

class PlaylistsModel: PlaylistsModelProtocol, PlaylistsEventHandler {
    var tracks: [Track] = []
    var channels: [Station] = []
    
    let realm: Realm? = try? Realm()
    
    var currentPlayingIndex: Int = -1

    var delegate: PlaylistsModelDelegate?
    var playlists: [(image: UIImage?, title: String, descr: String, tracks: [AudioTrack])] = []
    
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    let disposeBag = DisposeBag()
    
    init()
    {
        self.getData()
        
        InAppUpdateManager.shared.subscribe(self)
    }
    
    func getData() {
        RequestManager.shared.tracks(req: .magic).subscribe(onNext: { (tuple) in
            let tracklist = tuple.0.map({ (track) -> AudioTrack in
                return PlayerTrack.init(id: track.id, trackURL: track.url!, name: track.name, author: tuple.1.filter({track.stationId == $0.id}).first?.name ?? "", imageURL: track.image, length: track.length)
            })
            self.playlists = [(image: UIImage.init(named: "news"), title: "Fresh news in 30 minutes".localized, descr: "A compilation of fresh news in one 30-minute playlist".localized, tracks: tracklist)]
            self.getPlaylistViewModels()
        }).disposed(by: self.disposeBag)
    }
    
    func formatPlaylists(index: Int) {
        let playlist = self.playlists[index]
        let contr = AudioController.main
        contr.loadPlaylist(playlist: ("Playlist".localized + " \"\(playlist.title)\"", playlist.tracks.map({$0})), playId: playlist.tracks[0].id)
        contr.showPlaylist()
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
    
    func refresh() {
        self.getData()
    }
    
    func getPlaylistViewModels()
    {
        var playlistVMs: [PlaylistViewModel] = []
        for playlist in self.playlists
        {
            playlistVMs.append(PlaylistViewModel.init(image: UIImagePNGRepresentation(playlist.image!)!, title: playlist.title, description: playlist.descr))
        }
        self.delegate?.update(playlists: playlistVMs)
    }
}

extension PlaylistsModel: PlayingStateUpdateProtocol {
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
