//
//  ChannelsBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class ChannelsBuilder: Builder {
    static func build(params: [String : Any]?) -> UIViewController? {
        
        // for channels
        let channelsModel = CategoryChannelsModel(channelScreen: .small)
        let channelsVM = CategoryChannelsViewModel(model: channelsModel)
        let channelsEmitter = CategoryChannelsEmitter(model: channelsModel)
        let channelsView = ChannelsCollectionView.init(frame: CGRect.zero, emitter: channelsEmitter, viewModel: channelsVM)
        
        return UIViewController()
    }
}
