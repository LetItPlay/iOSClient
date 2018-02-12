//
//  LikesModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

protocol LikesModelProtocol {
    func getTracks()
}

protocol LikesModelDelegate: class {
    func reloadTracks(newTracks: [Track])
}

class LikesModel: LikesModelProtocol {
    
    weak var delegate: LikesModelDelegate?
    
    func getTracks() {
        let realm = try? Realm()
        let likeMan = LikeManager.shared
        let tracks = realm?.objects(Track.self).map({$0.detached()}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue}) ?? []
        
        self.delegate?.reloadTracks(newTracks: tracks)
    }
}
