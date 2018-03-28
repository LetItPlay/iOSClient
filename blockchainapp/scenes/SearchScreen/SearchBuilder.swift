//
//  SearchBuilder.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class SearchBuilder: Builder {
    static func build(params: [String: Any]?) -> UIViewController? {
        
        
//        // for playlist
//        let model = PlaylistsModel()
//        let vm = PlaylistsViewModel(model: model)
//        let emitter = PlaylistsEmitter(model: model)
        
        // for search
        let searchModel = SearchModel()
        let searchVM = SearchViewModel(model: searchModel)
        let searchEmitter = SearchEmitter(model: searchModel, viewModel: searchVM)
        
        let vc = SearchViewController(searchViewModel: searchVM, searchEmitter: searchEmitter)
        return vc
    }
}
