//
//  ChannelBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 23/02/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelBuilder: Builder {
	static func build(params: [String : Any]?) -> UIViewController? {
		if let id = params?["id"] as? Int, let station = params?["station"] as? Station1 {
			let model = ChannelModel(channelID: id)
			let cvm = ChannelViewModel(model: model)
			let fcvm = FullChannelViewModel(channel: station)
			let emitter = ChannelEmitter(model: model)
			return ChannelViewController(channel: fcvm, viewModel: cvm, emitter: emitter)
		}
		return nil
	}
}
