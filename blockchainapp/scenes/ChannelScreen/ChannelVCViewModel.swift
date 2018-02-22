////
////  ChannelVCViewModel.swift
////  blockchainapp
////
////  Created by Polina Abrosimova on 14.02.2018.
////  Copyright © 2018 Ivan Gorbulin. All rights reserved.
////
//
//import Foundation
//
//protocol ChannelVCVMProtocol {
//    var channel: FullChannelViewModel? {get}
//    var isSubscribed: Bool {get set}
//    var tracks: [TrackViewModel] {get}
//    
//    weak var delegate: ChannelVCVMDelegate? {get set}
//}
//
//protocol ChannelVCVMDelegate: class {
//    func reloadTracks()
//    func make(updates: [CollectionUpdate: [Int]])
//    func updateSubscription()
//}
//
//class ChannelVCViewModel: ChannelVCVMProtocol, ChannelVCModelDelegate {
//
//    var channel: FullChannelViewModel?
//    var isSubscribed: Bool = false
//    var tracks: [TrackViewModel] = []
//    
//    weak var delegate: ChannelVCVMDelegate?
//    var model: ChannelVCModelProtocol!
//    
//    init(model: ChannelVCModelProtocol)
//    {
//        self.model = model
//        self.model.delegate = self
//    }
//    
//    func followUpdate(isSubscribed: Bool) {
//        self.isSubscribed = isSubscribed
//        self.delegate?.updateSubscription()
//    }
//    
//    func reload(tracks: [TrackViewModel]) {
//        self.tracks = tracks
//        self.delegate?.reloadTracks()
//    }
//    
//    func trackUpdate(index: Int, vm: TrackViewModel) {
//        var vm = self.tracks[index]
//        vm.update(vm: vm)
//        self.tracks[index] = vm
//        self.delegate?.make(updates: [.update: [index]])
//    }
//}

