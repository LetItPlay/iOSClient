//
//  MainModels.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import RxSwift
import Action

class Tag: RealmString {
	
}

protocol LIPModel {
	var id: Int {get}
	var name: String {get}
	var image: URL? {get}
	var lang: String {get}
	var tags: [String] {get}
}

protocol TrackHandlingModelDelegate: class {
    func update(tracks: [Int: TrackViewModel])
    func show(tracks: [TrackViewModel], isContinue: Bool)
    func empty(show: Bool)
    func noDataLeft()
    func showChannel(id: Int)
    func showInfo(track: ShareInfo)
}

class TrackHandlingModel {
    private var currentOffest: Int = 0
    private let amount: Int = 100
    
    var playlistName: String = "Feed".localized
    var tracks: [Track] = []
    
    weak var delegate: TrackHandlingModelDelegate?
    
    private var dataAction: Action<Int, [Track]>?
    private let disposeBag = DisposeBag()
    
    init(name: String, dataAction: Action<Int, [Track]>) {
        
        self.dataAction = dataAction
        self.playlistName = name
        
        self.dataAction?.elements.do(onNext: { (tracks) in
            if self.currentOffest == 0 {
                self.tracks = tracks
            } else {
                self.tracks += tracks
            }
        }).map({ (tracks) -> [TrackViewModel] in
            let playingId = PlayerHandler.player?.playingNow
            return tracks.map({ TrackViewModel(track: $0,
                                               isPlaying: $0.id == playingId) })
        }).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
            self.delegate?.show(tracks: vms, isContinue: self.currentOffest != 0)
            self.delegate?.empty(show: self.tracks.count == 0)
            self.currentOffest = self.tracks.count
        }, onCompleted: {
            print("Track loaded")
        }).disposed(by: self.disposeBag)
        
        
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.dataAction?.execute(0)
        case .appear:
            self.delegate?.empty(show: self.tracks.count == 0)
        case .disappear:
            break
        case .deinitialize:
            break
        }
    }
}


extension TrackHandlingModel: PlayingStateUpdateProtocol {
    func trackPlayingUpdate(dict: [Int : Bool]) {
        var res: [Int: TrackViewModel] = [:]
        for tuple in dict {
            if let index = self.tracks.index(where: {tuple.key == $0.id}) {
                res[index] = TrackViewModel.init(track: self.tracks[index], isPlaying: tuple.value)
            }
        }
        self.delegate?.update(tracks: res)
    }
}

extension TrackHandlingModel: TrackEventHandler {
    func trackLiked(index: Int) {
        ServerUpdateManager.shared.make(track: self.tracks[index], action: .like)
    }
    
    func reload() {
        self.currentOffest = 0
        self.dataAction?.execute(0)
    }
    
    func trackShowed(index: Int) {
        if index > self.tracks.count - self.amount/10 {
            self.dataAction?.execute(self.tracks.count)
        }
    }
    
    func addTrack(index: Int, toBegining: Bool) {
        UserPlaylistManager.shared.add(track: self.tracks[index], toBegining: toBegining)
    }
    
    func showChannel(index: Int) {
        self.delegate?.showChannel(id: self.tracks[index].channel.id)
    }
    
    func showOthers(index: Int) {
        let track = self.tracks[index]
        self.delegate?.showInfo(track: track.sharedInfo())
    }
}

protocol TrackEventHandler: class, PlayerUsingProtocol {
    func reload()
    func trackLiked(index: Int)
    func trackShowed(index: Int)
    func showChannel(index: Int)
    func showOthers(index: Int)
    func addTrack(index: Int, toBegining: Bool)
}

protocol TrackHandlingViewModelDelegate: class {
    func reload(cells: [CollectionUpdate: [Int]]?)
    func reload()
    func reloadAppearence()
}

class TrackHandlingViewModel: TrackHandlingModelDelegate {
    
    weak var delegate: TrackHandlingViewModelDelegate?
    
    var data: [TrackViewModel] = []
    var title: String = "Default".localized
    var showEmpty: Bool = false
    var needUpload: Bool = true
    
    func update(tracks: [Int : TrackViewModel]) {
        for tuple in tracks {
            self.data[tuple.key] = tuple.value
        }
        self.delegate?.reload(cells: [.update: Array<Int>(tracks.keys)])
    }
    
    func show(tracks: [TrackViewModel], isContinue: Bool) {
        var cells: [CollectionUpdate: [Int]]?
        if isContinue {
            let insertStart = self.data.count
            self.data += tracks
            cells = [.insert: Array<Int>(insertStart..<self.data.count)]
        } else {
            self.data = tracks
        }
        self.delegate?.reload(cells: cells)
    }
    
    func empty(show: Bool) {
        self.showEmpty = true
        self.delegate?.reloadAppearence()
    }
    
    func noDataLeft() {
        self.needUpload = false
    }
    
    func showChannel(id: Int) {
        MainRouter.shared.show(screen: "channel", params: ["id" : id], present: false)
    }
    
    func showInfo(track: ShareInfo) {
        MainRouter.shared.showOthers(shareInfo: track)
    }
    
    
}
