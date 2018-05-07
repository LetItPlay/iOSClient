//
//  ChannelBuilder.swift
//  blockchainapp
//

import Foundation
import UIKit

class ChannelBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController? {
        
        var trackID: Int? = nil
        if let id = params!["trackID"],
            let _ = id as? Int {
            trackID = id as? Int
        }
        
        let model = ChannelModel(channelID: params!["id"] as! Int, playTrack: trackID)
        let vm = ChannelViewModel(model: model)
        let emitter = ChannelEmitter(model: model)
        
        let vc = ChannelViewController.init(viewModel: vm, emitter: emitter)
        return vc
    }
}
