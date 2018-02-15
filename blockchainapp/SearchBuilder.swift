//
//  SearchBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class SearchBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController {
        let model = PlaylistsModel()
        let vm = PlaylistsViewModel(model: model)
        let emitter = PlaylistsEmitter(model: model)
        let vc = SearchViewController.init(viewModel: vm, emitter: emitter)
        return vc
    }
}
