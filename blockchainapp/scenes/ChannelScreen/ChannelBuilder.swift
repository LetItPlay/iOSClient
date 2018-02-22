//
//  ChannelBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 22.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class ChannelBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController {
        
        let model = ChannelModel(channelID: params!["id"] as! Int)
        let vm = ChannelViewModel(model: model)
        let emitter = ChannelEmitter(model: model, station: params!["station"] as! Station)
        
        let vc = ChannelViewController.init(viewModel: vm, emitter: emitter)
        return vc
    }
}
