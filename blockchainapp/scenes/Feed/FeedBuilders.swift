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
        var isFeed: Bool = true
        if let _ = params, let feed = params!["isFeed"] as? Bool {
            isFeed = feed
        }
        
        let model = FeedModel(isFeed: isFeed)
        let vm = FeedViewModel()
        model.delegate = vm
        model.feedDelegate = vm
        let emitter = FeedEmitter(model: model)
        emitter.feedModel = model
        
        let vc = FeedViewController(viewModel: vm, emitter: emitter)
		return vc
	}
}
