//
//  TrackInfoBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class TrackInfoBuilder: Builder {
    static func build(params: [String : Any]?) -> UIViewController? {
        
        // for info header
        let model = TrackInfoModel(trackId: params!["id"] as! Int)
        let vm = TrackInfoViewModel()
        let emitter = TrackInfoEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        let view = TrackInfoHeaderView(emitter: emitter, viewModel: vm)
        let vc = TrackInfoViewController(view: view)
        
        return vc
    }
}
