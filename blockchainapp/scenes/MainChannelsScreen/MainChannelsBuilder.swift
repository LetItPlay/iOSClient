//
//  MainChannelsBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class MainChannelsBuilder: Builder {
    static func build(params: [String : Any]?) -> UIViewController? {
        
        // for subscribed
        let channelsModel = CategoryChannelsModel(channelScreen: .small, channelsFilter: .subscribed)
        let channelsVM = CategoryChannelsViewModel(model: channelsModel)
        let channelsEmitter = CategoryChannelsEmitter(model: channelsModel)
        let channelsView = ChannelsCollectionView.init(frame: CGRect.zero, emitter: channelsEmitter, viewModel: channelsVM)
        
        // for categories
        let mainModel = MainChannelsModel()
        let mainViewModel = MainChannelsViewModel(model: mainModel)
        let mainEmitter = MainChannelsEmitter(model: mainModel)
        
        let mainChannelsViewController = MainChannelsViewController(viewModel: mainViewModel, emitter: mainEmitter, channelsView: channelsView)
        
        return mainChannelsViewController
    }
}
