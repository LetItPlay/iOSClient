//
//  FeedBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import Action
import RxSwift

class FeedBuilder: Builder {
	static func build(params: [String: Any]?) -> UIViewController? {
        // for tracks
        let dataAction = Action<Int, [Track]>.init(workFactory: { (offset) -> Observable<[Track]> in
            return RequestManager.shared.tracks(req: TracksRequest.feed(offset: offset, count: 100))
        })
        
        // for feed
        let model = FeedModel(isFeed: true, name: LocalizedStrings.TabBar.feed, dataAction: dataAction)
        let vm = FeedViewModel()
        model.delegate = vm
        model.feedDelegate = vm
        let emitter = FeedEmitter(model: model)
        emitter.feedModel = model
        
        let vc = FeedViewController(viewModel: vm, emitter: emitter)
		return vc
	}
}

class PopularBuilder: Builder {
	static func build(params: [String: Any]?) -> UIViewController? {
        // for tracks
        let dataAction = Action<Int, [Track]>.init(workFactory: { (offset) -> Observable<[Track]> in
            return RequestManager.shared.tracks(req: TracksRequest.trends(offset: offset, count: 100))
        })
        
        // for trends
        let model = FeedModel(isFeed: false, name: LocalizedStrings.TabBar.trends, dataAction: dataAction)
        let vm = FeedViewModel()
        model.delegate = vm
        model.feedDelegate = vm
        let emitter = FeedEmitter(model: model)
        emitter.feedModel = model
        
        let vc = FeedViewController(viewModel: vm, emitter: emitter)
        return vc
	}
}
