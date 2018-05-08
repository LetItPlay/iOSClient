//
//  LikesViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol LikesVMProtocol {
    var tracks: [TrackViewModel] {get}
    var length: String {get set}
  
    var delegate: LikesVMDelegate? {get set}
}

protocol LikesVMDelegate: class {
    func reload()
    func make(updates: [CollectionUpdate: [Int]])
}

class LikesViewModel: LikesVMProtocol, LikesModelDelegate {
    
    var tracks: [TrackViewModel] = []
    var length: String = ""
    weak var delegate: LikesVMDelegate?
    
    var model : LikesModelProtocol!
    
    let disposeBag = DisposeBag()
    
    init(model: LikesModelProtocol)
    {
        self.model = model
        self.model.delegate = self
        
        self.model.playingIndex.asObservable().scan(nil) { (res, index) -> (Int?, Int?) in
            return (res?.1, index)
            }.subscribe(onNext: { (tuple) in
                if let tuple = tuple {
                    var indexes = [Int]()
                    if let old = tuple.0, self.tracks.count > old {
                        var vm = self.tracks[old]
                        vm.isPlaying = false
                        self.tracks[old] = vm
                        indexes.append(old)
                    }
                    if let new = tuple.1, self.tracks.count > new {
                        var vm = self.tracks[new]
                        vm.isPlaying = true
                        self.tracks[new] = vm
                        indexes.append(new)
                    }
                    self.delegate?.make(updates: [.update: indexes])
                }
            }).disposed(by: disposeBag)
    }
    
    func reload(tracks: [TrackViewModel], length: String) {
        self.tracks = tracks
        self.length = length
        self.delegate?.reload()
    }
    
    func show(tracks: [TrackViewModel], isContinue: Bool) {
        if isContinue {
            let indexes = self.tracks.count..<(self.tracks.count + tracks.count)
            self.tracks += tracks
            self.delegate?.make(updates: [.insert: Array(indexes)])
        } else {
            self.tracks = tracks
            self.delegate?.reload()
        }
    }
    
    func trackUpdate(index: Int, vm: TrackViewModel) {
        var vm = self.tracks[index]
        vm.update(vm: vm)
        self.tracks[index] = vm
        self.delegate?.make(updates: [.update: [index]])
    }
    
    func showOthers(track: ShareInfo) {
        MainRouter.shared.showOthers(track: track)
    }
}
