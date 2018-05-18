//
//  ChannelBuilder.swift
//  blockchainapp
//

import Foundation
import UIKit

class ChannelBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController? {
        
        guard let channelID = params!["id"] as? Int else {
            return UIViewController()
        }
        
        let model = ChannelModel(channelID: channelID)
        let vm = ChannelViewModel()
        model.channelDelegate = vm
        model.delegate = vm
        let emitter = ChannelEmitter(model: model)
        emitter.channelModel = model
        
        let vc = ChannelViewController.init(viewModel: vm, emitter: emitter)
        return vc
    }
}
