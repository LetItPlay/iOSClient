
//
//  UserPlaylistModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol UserPlaylistModelProtocol: ModelProtocol {
    var delegate: UserPlaylistModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol UserPlaylistEventHandler: class {
    func trackSelected(index: Int)
    func clearPlaylist()
    func trackDelete(index: Int)
    func showOthers(index: Int)
}

protocol UserPlaylistModelDelegate: class {
    func show(tracks: [TrackViewModel])
    func emptyMessage(show: Bool)
    func delete(index: Int)
    func showOthers(track: ShareInfo)
}

class UserPlaylistModel: UserPlaylistModelProtocol, UserPlaylistEventHandler, UserPlaylistDelegate, PlayerUsingProtocol
{
    weak var delegate: UserPlaylistModelDelegate?
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
	
	var playlistName: String = "My playlist".localized
	var tracks: [Track] = []
    private var tracksObs: Variable<[Track]> = Variable<[Track]>([])
	private var channels: [Channel] = []
    
    init()
    {
        UserPlaylistManager.shared.delegate = self
		self.channels = (try? Realm())?.objects(ChannelObject.self).map({$0.plain()}) ?? []
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func reload()
    {
        self.tracks = UserPlaylistManager.shared.tracks
        self.update(tracks: self.tracks)
    }

    func update(tracks: [Track]) {
        self.tracksObs.value = tracks
        self.tracks = tracks
        self.delegate?.emptyMessage(show: self.tracks.count == 0 ? true : false)
        self.delegate?.show(tracks: self.formVMs())
		let playlist = PlayerHandler.playlist
        if playlist?.playlistName == playlistName {
			playlist?.reload(tracks: self.tracks)
		}
    }

    func trackDelete(index: Int) {
		let playlist = PlayerHandler.playlist
		if playlist?.playlistName == playlistName {
			PlayerHandler.playlist?.remove(index: index)
		}
        UserPlaylistManager.shared.remove(index: index)
        self.tracks.remove(at: index)
        self.delegate?.delete(index: index)
        if self.tracks.count == 0 {
            self.delegate?.emptyMessage(show: true)
        }
    }

    func formVMs() -> [TrackViewModel] {
        return self.tracks.map({ (track) -> TrackViewModel in
            var vm = TrackViewModel.init(track: track)
            if let chan = self.channels.first(where: {$0.id == track.channel.id}) {
                vm.author = chan.name
                vm.authorImage = chan.image
            }
            vm.isPlaying = PlayerHandler.player?.playingNow == track.id
            return vm
        })
    }
    
    func clearPlaylist() {
        UserPlaylistManager.shared.tracks.removeAll()
        self.delegate?.emptyMessage(show: true)
        self.tracks = UserPlaylistManager.shared.tracks
        self.delegate?.show(tracks: self.tracks.map({TrackViewModel(track: $0)}))
		let playlist = PlayerHandler.playlist
		if playlist?.playlistName == playlistName {
            PlayerHandler.playlist?.clearAll(direction: .down)
		}
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
    
    func showOthers(index: Int) {
        self.delegate?.showOthers(track: self.tracks[index].sharedInfo())
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
