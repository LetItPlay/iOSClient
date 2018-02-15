//
//  FeedBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class FeedBuilder: Builder {
	static func build(params: [String: Any]?) -> UIViewController {
        let model = FeedModel(isFeed: true)
        let vm = FeedViewModel(model: model)
        let emitter = FeedEmitter(model: model)
		let vc = FeedViewController(vm: vm, emitter: emitter)
		return vc
	}
}

class PopularBuilder: Builder {
	static func build(params: [String: Any]?) -> UIViewController {
        let model = FeedModel(isFeed: false)
        let vm = FeedViewModel(model: model)
        let emitter = FeedEmitter(model: model)
        let vc = FeedViewController(vm: vm, emitter: emitter)
        return vc
	}
}
