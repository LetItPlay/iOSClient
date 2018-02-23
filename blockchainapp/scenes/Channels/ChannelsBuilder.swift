//
//  ChannelsBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

protocol Builder {
    static func build(params: [String: Any]?) -> UIViewController
}

class ChannelsBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController {

        let model = ChannelsModel(channelScreen: .medium)
        let vm = ChannelsViewModel(model: model)
        let emitter = ChannelsEmitter.init(model: model)
        
		let vc = ChannelsViewController.init(emitter: emitter, viewModel: vm)
		return vc
	}
}
