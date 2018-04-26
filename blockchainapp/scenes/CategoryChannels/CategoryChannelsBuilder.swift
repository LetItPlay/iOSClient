//
//  CategoryChannelsBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

protocol Builder {
    static func build(params: [String: Any]?) -> UIViewController?
}

class CategoryChannelsBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController? {

        let model = CategoryChannelsModel(channelScreen: .full)
        let vm = CategoryChannelsViewModel(model: model)
        let emitter = CategoryChannelsEmitter.init(model: model)
        
		let vc = CategoryChannelsViewController.init(emitter: emitter, viewModel: vm)
		return vc
	}
}
