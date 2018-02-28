//
//  SearchViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchVMProtocol {
    weak var delegate: SearchVMDelegate? {get set}
    var tracks: [TrackViewModel] {get set}
    var channels: [SearchChannelViewModel] {get set}
    var currentPlayingIndex: Int {get set}
}

protocol SearchVMEmitterProtocol: class {
    func getTypeFor(section: Int) -> ViewModels
}

protocol SearchVMDelegate: class {
    func make(updates: [CollectionUpdate: [Int]])
    func reloadTracks()
    func reloadChannels()
}

class SearchViewModel: SearchVMProtocol, SearchModelDelegate, SearchVMEmitterProtocol {
    
    var delegate: SearchVMDelegate?
    var model: SearchModelProtocol!
    
    var tracks: [TrackViewModel] = []
    var channels: [SearchChannelViewModel] = []
    
    var disposeBag = DisposeBag()
    
    var currentPlayingIndex: Int = -1
    
    init(model: SearchModelProtocol) {
        self.model = model
        self.model.delegate = self
        
        self.model.playingIndex.asObservable().scan(nil) { (res, index) -> (Int?, Int?) in
            return (res?.1, index)
            }.subscribe(onNext: { (tuple) in
                if self.channels.count != 0 || self.tracks.count != 0
                {
                    if let tuple = tuple {
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
                }
            }).disposed(by: disposeBag)
    }
    
    func update(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.reloadTracks()
    }
    
    func update(channels: [SearchChannelViewModel]) {
        self.channels = channels
        self.delegate?.reloadChannels()
    }
    
    func update(index: Int, vm: SearchChannelViewModel) {
        if channels.count > index {
            self.channels[index] = vm
            self.delegate?.reloadChannels()
        }
    }
    
    func showChannel(id: Int) {
        MainRouter.shared.show(screen: "channel", params: ["id": id], present: false)
    }
    
    // for emitter
    func getTypeFor(section: Int) -> ViewModels {
        switch section {
        case 0:
            return ViewModels.channels
        case 1:
            return ViewModels.tracks
        default:
            return ViewModels.channels
        }
    }
}
