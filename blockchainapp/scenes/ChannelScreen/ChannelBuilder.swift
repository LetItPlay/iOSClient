//
//  ChannelBuilder.swift
//  blockchainapp
//

import Foundation
import UIKit
import Action
import RxSwift

class ChannelBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController? {
        
        guard let channelID = params!["id"] as? Int else {
            return UIViewController()
        }
        
        let name = LocalizedStrings.Channels.channel + " \(channelID)"
        let getTracksAction = Action<Int, [Track]>.init(workFactory: { (offset) -> Observable<[Track]> in
            return RequestManager.shared.tracks(req: TracksRequest.channel(channelID))
        })
        
        let model = ChannelModel(channelID: channelID, name: name, dataAction: getTracksAction)
        let vm = ChannelViewModel()
        model.channelDelegate = vm
        model.delegate = vm
        let emitter = ChannelEmitter(model: model)
        emitter.channelModel = model
        
        let vc = ChannelViewController.init(viewModel: vm, emitter: emitter)
        return vc
    }
}
