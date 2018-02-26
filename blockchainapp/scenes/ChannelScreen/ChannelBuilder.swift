//
//  ChannelBuilder.swift
//  blockchainapp
//

import Foundation
import UIKit

class ChannelBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController? {
        
        let model = ChannelModel(channelID: params!["id"] as! Int)
        let vm = ChannelViewModel(model: model)
        let emitter = ChannelEmitter(model: model, station: params!["station"] as! Station1)
        
        let vc = ChannelViewController.init(viewModel: vm, emitter: emitter)
        return vc
    }
}
