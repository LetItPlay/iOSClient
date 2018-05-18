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
import Action

protocol LikesModelProtocol: ModelProtocol {
}

protocol LikesEventHandler: class {
    func hidePlayer()
}

protocol LikesModelDelegate: class {
}

class LikesModel: TrackHandlingModel, LikesModelProtocol, LikesEventHandler {
    init() {
        let dataAction = Action<Int, [Track]>.init(workFactory: { (_) -> Observable<[Track]> in
            return RequestManager.shared.tracks(req: TracksRequest.likes)
        })
            
        super.init(name: LocalizedStrings.Profile.like, dataAction: dataAction)
    }
    
    func hidePlayer() {
        PlayerHandler.playlist?.clearAll(direction: .down)
    }
    
    override func trackUpdated(track: Track) {
        if track.isLiked {
            if let index = self.tracks.index(where: {$0.id == track.id}) {
                self.tracks[index] = track
                self.delegate?.update(tracks: [index: TrackViewModel(track: track)], length: self.tracksLength())
            } else {
                self.tracks.append(track)
                self.delegate?.show(tracks: self.tracks.map({TrackViewModel(track: $0)}), isContinue: false, length: self.tracksLength())
            }
        } else {
            if let index = self.tracks.index(where: {$0.id == track.id}) {
                self.tracks.remove(at: index)
            }
            self.delegate?.show(tracks: self.tracks.map({TrackViewModel(track: $0)}), isContinue: false, length: self.tracksLength())
        }
    }
}

extension PlayingStateUpdateProtocol {
    func transform(tracks: [Track], dict: [Int: Bool]) -> [Int: TrackViewModel] {
        var res = [Int: TrackViewModel]()
        for tuple in dict {
            if let index = tracks.index(where: {tuple.0 == $0.id}) {
                res[index] = TrackViewModel.init(track: tracks[index], isPlaying: tuple.value)
            }
        }
        return res
    }
}
