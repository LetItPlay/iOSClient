//
//  ChannelsBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

protocol Builder {
	static func build() -> UIViewController
}

class ChannelsBuilder: Builder {
	static func build() -> UIViewController {
        
        let model = ChannelsVCModel()
        let vm = ChannelsVCViewModel()
        let emitter = ChannelsVCEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
		let vc = ChannelsViewController.init(emitter: emitter, viewModel: vm)
		return vc
	}
}
