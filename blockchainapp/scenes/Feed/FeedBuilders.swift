//
//  FeedBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class FeedBuilder: Builder {
	static func build(params: [String: Any]?) -> UIViewController? {
        // for feed
        let model = FeedModel(isFeed: true)
        let vm = FeedViewModel(model: model)
        let emitter = FeedEmitter(model: model)
        
        // for search
        let searchModel = SearchModel()
        let searchVM = SearchViewModel(model: searchModel)
        let searchEmitter = SearchEmitter(model: searchModel, viewModel: searchVM)
        
        let vc = FeedViewController(vm: vm, emitter: emitter, channelsView: ChannelsCollectionView(), searchViewModel: searchVM, searchEmitter: searchEmitter)
		return vc
	}
}

class PopularBuilder: Builder {
	static func build(params: [String: Any]?) -> UIViewController? {
        // for channels
        let channelsModel = ChannelsModel(channelScreen: .small)
        let channelsVM = ChannelsViewModel(model: channelsModel)
        let channelsEmitter = ChannelsEmitter(model: channelsModel)
        let channelsView = ChannelsCollectionView.init(frame: CGRect.zero, emitter: channelsEmitter, viewModel: channelsVM)
        
        // for feed
        let model = FeedModel(isFeed: false)
        let vm = FeedViewModel(model: model)
        let emitter = FeedEmitter(model: model)
        
        // for search
        let searchModel = SearchModel()
        let searchVM = SearchViewModel(model: searchModel)
        let searchEmitter = SearchEmitter(model: searchModel, viewModel: searchVM)
        
        let vc = FeedViewController(vm: vm, emitter: emitter, channelsView: channelsView, searchViewModel: searchVM, searchEmitter: searchEmitter)
        return vc
	}
}
