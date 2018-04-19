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
    weak var delegate: SearchModelDelegate? {get set}
    var playingIndex: Variable<Int?> {get}
}

protocol SearchEventHandler: class {
    func cellDidSelectFor(viewModels: ViewModels, atIndex: Int)
    func channelSubscriptionPressedAt(index: Int)
    func searchChanged(string: String)
}

protocol SearchModelDelegate: class {
    func update(tracks: [TrackViewModel])
    func update(channels: [SearchChannelViewModel])
    func update(index: Int, vm: SearchChannelViewModel)
    func update(index: Int, vm: TrackViewModel)
    func showChannel(id: Int)
}

class SearchModel: SearchModelProtocol, SearchEventHandler, PlayerUsingProtocol {
	
	var playlistName: String = "Search".localized
    var tracks: [Track] = []
    var channels: [Channel] = []
//    var searchTracks: [Track] = []
//    var searchChannels: [Channel] = []
	
    var playingIndex: Variable<Int?> = Variable<Int?>(nil)
    var currentSearchString: String = ""
    var prevSearchString: String = ""
    
    let realm: Realm? = try? Realm()
    
    var delegate: SearchModelDelegate?
	
	let searchState: Variable<(text: String?, offset: Int)> = Variable<(text: String?, offset: Int)>((nil,0))
    let disposeBag = DisposeBag()
    
    init()
    {
		searchState.asObservable()
			.flatMap { tuple -> Observable<([Track], [Channel])> in
				if let q = tuple.0, q != "" {
					return RequestManager.shared.search(text: q, offset: tuple.1, count: 100)
				} else {
					return Observable.just(([Track](),[Channel]()))
					
				}
			}.subscribe(onNext: {(tuple) in
				self.playlistName = "Seacrh".localized + " \"\(self.searchState.value.text)\""
 				self.tracks = tuple.0
				self.channels = tuple.1
				self.delegate?.update(tracks: self.tracks.map({TrackViewModel.init(track: $0)}))
				self.delegate?.update(channels: self.channels.map({SearchChannelViewModel.init(channel: $0)}))
//				self.searchChanged(string: self.currentSearchString)
			}).disposed(by: self.disposeBag)
//        Observable<([Track], [Channel])>.combineLatest(RequestManager.shared.tracks(req: .allTracks), RequestManager.shared.channels()) { (tracksTuple, channels) -> ([Track], [Channel]) in
//            return (tracksTuple, channels)
//            }.subscribe(onNext: {(tuple) in
//                self.tracks = tuple.0
//                self.channels = tuple.1
//                self.searchChanged(string: self.currentSearchString)
//            }).disposed(by: self.disposeBag)
		
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
//        self.playingIndex.value = nil
//        self.prevSearchString = self.currentSearchString
//        self.currentSearchString = string.lowercased()
//        if string.count == 0 {
//            self.searchChannels = []
//            self.searchTracks = []
//
//            self.delegate?.update(tracks: self.searchTracks.map({TrackViewModel.init(track: $0)}))
//            self.delegate?.update(channels: self.searchChannels.map({SearchChannelViewModel(channel: $0)}))
//        } else {
//            var tracksPool = self.tracks
//            if prevSearchString != "" && currentSearchString.contains(prevSearchString) {
//                tracksPool = self.searchTracks
//            }
//            self.searchTracks = tracksPool.filter({ track in
//                if track.name.lowercased().range(of: self.currentSearchString) != nil
//                {
//                    return true
//                }
//
//                if track.tags.count != 0 {
//                    for tag in track.tags
//                    {
//                        if tag.lowercased().range(of: self.currentSearchString) != nil
//                        {
//                            return true
//                        }
//                    }
//                }
//                else
//                {
//                    for tag in (channels.filter({$0.id == track.channel.id}).first?.tags)!
//                    {
//                        if tag.lowercased().range(of: self.currentSearchString) != nil
//                        {
//                            return true
//                        }
//                    }
//                }
//
//                return false
//            })
//
//            var trackPlayingIndex: Int = -1
//            self.delegate?.update(tracks: self.searchTracks.map({ (track) -> TrackViewModel in
//                var vm = TrackViewModel(track: track)
//
//                if track.id == AudioController.main.currentTrack?.id
//                {
//                    vm.isPlaying = true
//                    trackPlayingIndex = self.searchTracks.index(where: {$0.id == track.id})!
//                }
//
//                if let channel = self.channels.first(where: {$0.id == track.channel.id}) {
//                    vm.author = channel.name
//                    vm.authorImage = channel.image
//                }
//                return vm
//            }))
//            self.playingIndex.value = trackPlayingIndex
//
//            self.searchChannels = self.channels.filter({ channel in
//                if channel.name.lowercased().range(of: self.currentSearchString) != nil
//                {
//                    return true
//                }
//
//                for tag in channel.tags
//                {
//                    if tag.contains(self.currentSearchString)
//                    {
//                        return true
//                    }
//                }
//                return false
//            })
//            self.delegate?.update(channels: self.searchChannels.map({SearchChannelViewModel(channel: $0)}))
//        }
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
        let action: ChannelAction = channel.isSubscribed ? ChannelAction.unsubscribe : ChannelAction.subscribe
        ServerUpdateManager.shared.make(channel: channel, action: action)
        
        // while in User Settings
        SubscribeManager.shared.addOrDelete(channel: channel.id)
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
