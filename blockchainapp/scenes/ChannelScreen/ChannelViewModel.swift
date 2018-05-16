//
//  ChannelVCViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol ChannelVMProtocol {
    var channel: FullChannelViewModel? {get}
    var isSubscribed: Bool {get set}
    var tracks: [TrackViewModel] {get}
    
    var delegate: ChannelVMDelegate? {get set}
}

protocol ChannelVMDelegate: class {
    func reloadTracks()
    func make(updates: [CollectionUpdate: [Int]])
    func updateSubscription()
}

class ChannelViewModel: ChannelVMProtocol, ChannelModelDelegate {

    var channel: FullChannelViewModel?
    var isSubscribed: Bool = false
    var tracks: [TrackViewModel] = []
    
    weak var delegate: ChannelVMDelegate?
    var model: ChannelModelProtocol!
    
    let disposeBag = DisposeBag()

    init(model: ChannelModelProtocol)
    {
        self.model = model
        self.model.delegate = self
        
        self.model.playingIndex.asObservable().scan(nil) { (res, index) -> (Int?, Int?) in
            return (res?.1, index)
            }.subscribe(onNext: { (tuple) in
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
            }).disposed(by: disposeBag)
    }
    
    func followUpdate(isSubscribed: Bool) {
        self.channel?.isSubscribed = isSubscribed
        self.isSubscribed = isSubscribed
        self.delegate?.updateSubscription()
    }
    
    func reload(tracks: [TrackViewModel]) {
        self.tracks = tracks
        self.delegate?.reloadTracks()
    }
    
    func trackUpdate(index: Int, vm: TrackViewModel) {
        var vm = self.tracks[index]
        vm.update(vm: vm)
        self.tracks[index] = vm
        self.delegate?.make(updates: [.update: [index]])
    }
    
    func trackUpdate(dict: [Int : TrackViewModel]) {
        for tuple in dict {
            self.tracks[tuple.key] = tuple.value
        }
        self.delegate?.reloadTracks()
    }
    
    func getChannel(channel: FullChannelViewModel) {
        self.channel = channel
        self.isSubscribed = channel.isSubscribed
        self.delegate?.updateSubscription()
    }
    
    func showSearch(text: String?) {
        MainRouter.shared.show(screen: "search", params: ["text" : text as Any], present: false)
    }
    
    func showOthers(shareInfo: ShareInfo) {
        MainRouter.shared.showOthers(shareInfo: shareInfo)
    }
}

