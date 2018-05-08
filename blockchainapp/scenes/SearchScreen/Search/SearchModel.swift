//
//  SearchModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum ViewModels {
    case channels, tracks
}

protocol SearchModelProtocol: ModelProtocol {
    var delegate: SearchModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol SearchEventHandler: class {
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int)
    func channelSubscriptionPressedAt(index: Int)
    func searchChanged(string: String)
    func showOthers(index: Int)
    func showMoreTracks()
}

protocol SearchModelDelegate: class {
    func update(tracks: [TrackViewModel])
    func update(channels: [SearchChannelViewModel])
    func update(index: Int, vm: SearchChannelViewModel)
    func update(index: Int, vm: TrackViewModel)
    func showChannel(id: Int)
    func showOthers(track: ShareInfo)
    func toUpdate(nothing: Bool)
}

class SearchModel: SearchModelProtocol, SearchEventHandler, PlayerUsingProtocol {
	
	var playlistName: String = "Search".localized
    var tracks: [Track] = []
    var channels: [Channel] = []
    var tracksCount: Int = 100
	
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    var currentSearchString: String = ""
    var prevSearchString: String = ""
    
    let realm: Realm? = try? Realm()
    
    weak var delegate: SearchModelDelegate?
	
	let searchState: Variable<(text: String?, offset: Int)> = Variable<(text: String?, offset: Int)>((nil,0))
    let disposeBag = DisposeBag()
    
    init()
    {
		searchState.asObservable()
			.flatMap { tuple -> Observable<([Track], [Channel])> in
				if let q = tuple.0, q != "" {
                    return RequestManager.shared.search(text: q, offset: tuple.1, count: self.tracksCount)
				} else {
					return Observable.just(([Track](),[Channel]()))
					
				}
			}.subscribe(onNext: {(tuple) in
                if self.searchState.value.offset == 0 {
                    self.delegate?.toUpdate(nothing: false)
                    self.playlistName = "Search".localized + " \"\(self.searchState.value.text ?? "")\""
                    self.tracks = tuple.0
                    self.channels = tuple.1
                    self.delegate?.update(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
                    self.delegate?.update(channels: self.channels.map({SearchChannelViewModel.init(channel: $0)}))
                } else {
                    if tuple.0.count == 0 {
                        self.delegate?.toUpdate(nothing: true)
                    }
                    self.tracks += tuple.0
                    self.delegate?.update(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
                }
			}).disposed(by: self.disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
    
    func searchChanged(string: String) {
		self.searchState.value = (string, 0)
    }
    
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int) {
        switch viewModels {
        case .channels:
            AnalyticsEngine.sendEvent(event: .searchEvent(event: .channelTapped))
            self.delegate?.showChannel(id: self.channels[atIndex].id)
        case .tracks:
            AnalyticsEngine.sendEvent(event: .searchEvent(event: .trackTapped))
            self.trackSelected(index: atIndex)
        }
    }
    
    func channelSubscriptionPressedAt(index: Int) {
        let channel = self.tracks.count != 0 ? self.channels[index] : self.channels[index]
        let action: ChannelAction = ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        
        // while in User Settings
        SubscribeManager.shared.addOrDelete(channel: channel.id)
    }
    
    func showOthers(index: Int) {
        self.delegate?.showOthers(track: self.tracks[index].sharedInfo())
    }
    
    func showMoreTracks() {
        if self.tracks.count != 0 {
            self.searchState.value.offset = self.tracksCount
        }
    }
}

extension SearchModel: ChannelUpdateProtocol, PlayingStateUpdateProtocol {
    
    func trackPlayingUpdate(id: Int, isPlaying: Bool) {
        if isPlaying {
            if let index = self.tracks.index(where: {$0.id == id})
            {
                self.playingIndex.value = index
            }
        } else {
            self.playingIndex.value = nil
        }
    }
    
    func channelUpdated(channel: Channel) {
        if let index = self.channels.index(where: {$0.id == channel.id}) {
            self.channels[index] = channel
            var oldChannel = channel
            oldChannel.isSubscribed = !oldChannel.isSubscribed
            var searchIndex = index

            if self.channels.count != 0
            {
                if let someIndex: Int = self.channels.index(of: oldChannel)
                {
                    searchIndex = someIndex
                    self.channels[searchIndex] = channel
                }
            }

            self.delegate?.update(index: searchIndex, vm: SearchChannelViewModel(channel: channel))
        }
    }
}
