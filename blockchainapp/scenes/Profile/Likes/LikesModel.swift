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
            let realm = try? Realm()
            let likeMan = LikeManager.shared
            return Observable.just(realm?.objects(TrackObject.self).map({Track.init(track: $0)}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.identifier}) ?? [])
        })
            
        super.init(name: LocalizedStrings.Profile.like, dataAction: dataAction)
    }
    
    func hidePlayer() {
        PlayerHandler.playlist?.clearAll(direction: .down)
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
