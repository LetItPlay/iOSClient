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

protocol LikesModelProtocol {
    func getTracks()
}

protocol LikesModelDelegate: class {
    func reload(tracks: [TrackViewModel])
    func update(index: Int, track: TrackViewModel)
}

class LikesModel: LikesModelProtocol {
    
    weak var delegate: LikesModelDelegate?
    private var token: NotificationToken?
    
    private var tracks: [Track] = []
    private var playingIndex: Int? = nil
    
    private let disposeBag = DisposeBag()
    
    init() {
        if let realm = try? Realm() {
            let likeMan = LikeManager.shared
//            let tracks = realm.objects(Track.self).map({$0.detached()}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue})
            let results = realm.objects(Track.self).filter("lang contains %@", UserSettings.language.rawValue)
            
            token = results.observe({ (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
//                    self.tracks = Array(results).filter(self.filter).sorted(by: { (first, second) -> Bool in
//                        if let res = self.sort(first, second) {
//                            return res
//                        } else {
//                            return first.name < second.name
//                        }
//                    })
                    self.delegate?.reload(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
                    
                case .update(_, let deletions, let insertions, let modifications):
                    // Query results have changed, so apply them to the UITableView
//                    self.tracks = Array(results).filter(self.filter).sorted(by: { (first, second) -> Bool in
//                        if let res = self.sort(first, second) {
//                            return res
//                        } else {
//                            return first.name < second.name
//                        }
//                    })
                    self.delegate?.reload(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
                    let update = modifications.map({ (index) -> (Int, Track)? in
                        if let index = self.tracks.index(where: {$0.id == results[index].id}) {
                            return (index, results[index])
                        }
                        return nil
                    }).filter({$0 != nil}).map({$0!})
                    //                    let delete = deletions.map({ (index) -> Int? in
                    //                        return self?.tracks.index(where: {$0.id == results[index].id})
                    //                    }).filter({$0 != nil}).map({$0!})
                    //                    let insert = insertions.map({ (index) -> Int? in
                    //                        return self?.tracks.index(where: {$0.id == results[index].id})
                    //                    }).filter({$0 != nil}).map({$0!})
                    //                    self?.view?.reload(update: update, delete: delete, insert: insert)
                    update.forEach({ (ind) in
                        self.delegate?.update(index: ind.0, track: TrackViewModel(track: ind.1))
                    })
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            })
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPlayed(notification:)),
                                               name: AudioController.AudioStateNotification.playing.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackPaused(notification:)),
                                               name: AudioController.AudioStateNotification.paused.notification(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(settingsChanged(notification:)),
                                               name: SettingsNotfification.changed.notification(),
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        token?.invalidate()
    }
    
    @objc func settingsChanged(notification: Notification) {
//        self.delegate?.reload(tracks: <#T##[TrackViewModel]#>)
    }
    
    @objc func trackPlayed(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let index = self.tracks.index(where: {$0.audiotrackId() == id}) {
            self.playingIndex = index
        }
    }
    
    @objc func trackPaused(notification: Notification) {
        if let id = notification.userInfo?["ItemID"] as? String, let _ = self.tracks.index(where: {$0.audiotrackId() == id}) {
            self.playingIndex = -1
        }
    }
    
    func getTracks() {
        DownloadManager.shared.channelsSignal().observeOn(MainScheduler.init()).flatMap({ (_) -> Observable<[Track]> in
            return DownloadManager.shared.requestTracks(all: true)
        }).subscribe( onCompleted: {
            print("Tracks dowloaded")
        }) .disposed(by: self.disposeBag)
    }
}
