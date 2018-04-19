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
    weak var delegate: LikesModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol LikesEventHandler: class
{
    func getTracks()
    func trackSelected(index: Int)
    func showOthers(index: Int)

}

protocol LikesModelDelegate: class {
    func reload(tracks: [TrackViewModel], length: String)
    func trackUpdate(index: Int, vm: TrackViewModel)
    func show(tracks: [TrackViewModel], isContinue: Bool)
    func showOthers(track: Track)
}

class LikesModel: LikesModelProtocol, LikesEventHandler, PlayerUsingProtocol {

    weak var delegate: LikesModelDelegate?
    private var token: NotificationToken?
    
    private var channels: Set<Channel> = Set<Channel>()
    private var trackChannels: [Channel] = []
	var tracks: [Track] = []
	var playlistName: String = "Like".localized
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    private var currentOffest: Int = 0
    
    private var getTrackAction: Action<Int, ([Track],[Channel])>?
    
    private let disposeBag = DisposeBag()
    
    init() {
//        getTrackAction = Action<Int, ([Track],[Channel])>.init(workFactory: { (offset) -> Observable<([Track],[Channel])> in
//            return RequestManager.shared.tracks(req: TracksRequest.likes)
//        })
//
//        getTrackAction?.elements.do(onNext: { (tuple) in
//            if self.currentOffest == 0 {
//                self.tracks = tuple.0.map({TrackObject.init(track: $0)})
//            } else {
//                self.tracks += tuple.0.map({TrackObject.init(track: $0)})
//            }
//            tuple.1.forEach({ (channel) in
//                self.channels.insert(channel)
//            })
//        }).map({ (tuple) -> [TrackViewModel] in
//            let playingId = AudioController.main.currentTrack?.id
//            return tuple.0.map({ (track) -> TrackViewModel in
//                var vm = TrackViewModel(track: track,
//                                        isPlaying: track.id == playingId)
//                if let channel = tuple.1.filter({$0.id == track.channelId}).first {
//                    vm.authorImage = channel.image
//                    vm.author = channel.name
//                }
//                return vm
//            })
//        }).subscribeOn(MainScheduler.instance).subscribe(onNext: { (vms) in
//            self.delegate?.show(tracks: vms, isContinue: self.currentOffest != 0)
//            self.currentOffest = self.tracks.count
//        }, onCompleted: {
//            print("Track loaded")
//        }).disposed(by: self.disposeBag)
        
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func getTracks() {
        let realm = try? Realm()
        let likeMan = LikeManager.shared
		self.tracks = realm?.objects(TrackObject.self).map({Track.init(track: $0)}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue}) ?? []

        self.getTracksViewModel()
    }
    
    func getTracksViewModel()
    {
        let playingID = PlayerHandler.player?.playingNow
        
        var length: Int64 = 0
        var tracksVMs = [TrackViewModel]()
        for i in 0..<tracks.count
        {
            let playingResult = self.tracks[i].id == playingID
            
            tracksVMs.append(TrackViewModel(track: tracks[i], isPlaying: playingResult))
            
            self.playingIndex.value = playingResult ? i : self.playingIndex.value
            
            length += tracks[i].length
        }
        
        self.delegate?.reload(tracks: tracksVMs, length: length.formatTime())
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
//            self.getTrackAction?.execute(0)
            break
        case .appear:
            self.getTracks()
			self.playlistName = "Like".localized + " \(self.tracks.count)"
            break
        default:
            break
        }
    }
    
    func showOthers(index: Int) {
        self.delegate?.showOthers(track: self.tracks[index])
    }
}

extension LikesModel: PlayingStateUpdateProtocol, TrackUpdateProtocol, SettingsUpdateProtocol {
    func settingsUpdated() {
        self.getTracks()
    }
    
    func trackPlayingUpdate(id: Int, isPlaying: Bool) {
        if isPlaying {
            if let index = self.tracks.index(where: {$0.id == id}) {
                self.playingIndex.value = index
            }
        } else {
            self.playingIndex.value = nil
        }
    }
    
    func trackUpdated(track: Track) {
        if let index = self.tracks.index(where: {$0.id == track.id}) {
            let vm = TrackViewModel(track: track)
            self.delegate?.trackUpdate(index: index, vm: vm)
        }
    }
}
