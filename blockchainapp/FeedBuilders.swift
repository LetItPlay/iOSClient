//
//  FeedBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class FeedBuilder: Builder {
	static func build() -> UIViewController {
        let model = ChannelsModel()
        let vm = ChannelsViewModel()
        let emitter = ChannelsEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        let view = ChannelsCollectionView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), emitter: emitter, viewModel: vm)
        let vc = FeedViewController(type: .feed, view: view)
		return vc
	}
}

class PopularBuilder: Builder {
	static func build() -> UIViewController {
        let model = ChannelsModel()
        let vm = ChannelsViewModel()
        let emitter = ChannelsEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        let view = ChannelsCollectionView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), emitter: emitter, viewModel: vm)
        let vc = FeedViewController(type: .popular, view: view)
        
		return vc
	}
}
