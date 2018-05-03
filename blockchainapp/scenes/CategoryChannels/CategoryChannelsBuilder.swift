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
        
        var topInset: Bool = false
        var channelsFilter: ChannelsFilter!
        
        if let _ = params {
            if let inset = params!["topInset"] {
                topInset = inset as! Bool
            }
            
            if let filter = params!["filter"] {
                channelsFilter = filter as! ChannelsFilter
            } else {
                channelsFilter = ChannelsFilter.all
            }
        }

        let model = CategoryChannelsModel(channelScreen: .full, channelsFilter: channelsFilter)
        let vm = CategoryChannelsViewModel(model: model)
        let emitter = CategoryChannelsEmitter.init(model: model)
        
        let vc = CategoryChannelsViewController.init(emitter: emitter, viewModel: vm, topInset: topInset)
		return vc
	}
}
