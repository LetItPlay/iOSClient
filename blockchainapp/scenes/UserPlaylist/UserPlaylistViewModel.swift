//
//  UserPlaylistViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol UserPlaylistVMProtocol {
    var tracks: [TrackViewModel] {get}
    
    weak var delegate: UserPlaylistVMDelegate? {get set}
}

protocol UserPlaylistVMDelegate: class {
    func make(updates: [CollectionUpdate: [Int]])
}

class UserPlaylistViewModel: UserPlaylistVMProtocol, UserPlaylistModelDelegate
{
    var delegate: UserPlaylistVMDelegate?
    var tracks: [TrackViewModel] = []
    
    var model: UserPlaylistModelProtocol!
    
    let disposeBag = DisposeBag()
    
    init(model: UserPlaylistModelProtocol)
    {
        self.model = model
        self.model.delegate = self
        
        self.model.playingIndex.asObservable().scan(nil) { (res, index) -> (Int?, Int?) in
            return (res?.1, index)
            }.subscribe(onNext: { (tuple) in
                if let tuple = tuple, self.tracks.count != 0 {
                    var indexes = [Int]()
                    if let old = tuple.0 {
                        var vm = self.tracks[old]
                        vm.isPlaying = false
                        self.tracks[old] = vm
                        indexes.append(old)
                    }
                    if let new = tuple.1 {
                        var vm = self.tracks[new]
                        vm.isPlaying = true
                        self.tracks[new] = vm
                        indexes.append(new)
                    }
                    self.delegate?.make(updates: [.update: indexes])
                }
            }).disposed(by: disposeBag)
    }
}
