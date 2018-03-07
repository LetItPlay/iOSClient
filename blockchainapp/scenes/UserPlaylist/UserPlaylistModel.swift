
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

protocol UserPlaylistModelProtocol: class, ModelProtocol {
    weak var delegate: UserPlaylistModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol UserPlaylistEventHandler: class {
    func trackSelected(index: Int)
    func clearPlaylist()
    func trackDelete(index: Int)
}

protocol UserPlaylistModelDelegate: class {
    func show(tracks: [TrackViewModel])
    func emptyMessage(show: Bool)
    func delete(index: Int)
}

class UserPlaylistModel: UserPlaylistModelProtocol, UserPlaylistEventHandler, UserPlaylistDelegate
{
    var delegate: UserPlaylistModelDelegate?
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    
    private var tracks: [Track] = []
    private var tracksObs: Variable<[Track]> = Variable<[Track]>([])
	private var channels: [Channel] = []
    
    init()
    {
        UserPlaylistManager.shared.delegate = self
		self.channels = (try? Realm())?.objects(ChannelObject.self).map({$0.plain()}) ?? []
        InAppUpdateManager.shared.subscribe(self)
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
        let audioContr = AudioController.main
        if audioContr.playlist.name == "My playlist".localized {
            let audioTracks = self.tracks.map { track -> AudioTrack in
                return track.audioTrack(author: self.channels.first(where: {$0.id == track.channelId})?.name ?? "")
            }
            audioContr.update(.reload(tracks: audioTracks))
        }
    }

    func trackDelete(index: Int) {
        AudioController.main.update(.remove(id: self.tracks[index].id))
        UserPlaylistManager.shared.remove(index: index)
        self.tracks.remove(at: index)
        self.delegate?.delete(index: index)
//        self.delegate?.show(tracks: self.formVMs())
        if self.tracks.count == 0 {
            self.delegate?.emptyMessage(show: true)
        }
    }

    func formVMs() -> [TrackViewModel] {
        return self.tracks.map({ (track) -> TrackViewModel in
            var vm = TrackViewModel.init(track: track)
            if let chan = self.channels.first(where: {$0.id == track.channelId}) {
                vm.author = chan.name
                vm.authorImage = chan.image
            }
            vm.isPlaying = AudioController.main.currentTrack?.id == track.id
            return vm
        })
    }

    func trackSelected(index: Int) {
        let tracks = self.tracks.map { (track) -> AudioTrack in
            return track.audioTrack(author: channels.first(where: {$0.id == track.channelId})?.name ?? "")
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
