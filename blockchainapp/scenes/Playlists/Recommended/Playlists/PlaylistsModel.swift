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
import Action

protocol PlaylistsModelProtocol: ModelProtocol {
    var delegate: PlaylistsModelDelegate? {get set}
}

protocol PlaylistsEventHandler: class {
    func formatPlaylists(index: Int)
    func refresh()
}

protocol PlaylistsModelDelegate: class {
    func update(playlists: [PlaylistViewModel])
//    func trackUpdate(dict: [Int: TrackViewModel])
}

class PlaylistsModel: PlaylistsModelProtocol, PlaylistsEventHandler {
    
    let realm: Realm? = try? Realm()
    
    var currentPlayingIndex: Int = -1

    weak var delegate: PlaylistsModelDelegate?
    var playlists: [(image: UIImage?, title: String, descr: String, tracks: [Track])] = []
    
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
	
	var dataAction: Action<Bool,[Track]>!
    let disposeBag = DisposeBag()
    
    init()
    {
		self.dataAction = Action<Bool,[Track]>.init(workFactory: { (_) -> Observable<[Track]> in
			return RequestManager.shared.tracks(req: .magic)
		})
		
		self.dataAction.elements.subscribe(onNext: { (audio) in
			self.playlists = [(image: UIImage.init(named: "news"), title: LocalizedStrings.Playlists.recommendedTitle, descr: LocalizedStrings.Playlists.recommendedDescription, tracks: audio)]
			self.getPlaylistViewModels()
		}).disposed(by: disposeBag)
		
        let _ = InAppUpdateManager.shared.subscribe(self)
		
        self.getData()
    }
	
    func getData() {
        self.dataAction.execute(true)
    }

    func formatPlaylists(index: Int) {
        let playlist = self.playlists[index]
		let name = LocalizedStrings.Playlists.playlist + " \"\(playlist.title)\""
		let player = PlayerHandler.player
		player?.loadPlaylist(name: name, tracks: playlist.tracks)
		let _ = player?.trackSelected(playlistName: name, id: playlist.tracks[0].id)
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

extension PlaylistsModel: PlayingStateUpdateProtocol, SettingsUpdateProtocol, TrackUpdateProtocol {
    
    func trackPlayingUpdate(dict: [Int : Bool]) {
//        self.delegate?.trackUpdate(dict: self.transform(tracks: self.playlists[0].tracks, dict: dict))
    }
    
    func trackUpdated(track: Track) {
//        if let index = self.playlists[0].tracks.index(where: {$0.id == track.id}) {
//            let vm = TrackViewModel(track: track)
//            self.playlists[0].tracks[index] = track
//            self.delegate?.trackUpdate(dict: [index: vm])
//        }
    }
    
	func settingsUpdated() {
		self.refresh()
	}
}
