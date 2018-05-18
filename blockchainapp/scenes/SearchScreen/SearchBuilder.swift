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

        var text: String? = nil
        if let _ = params, let string = params!["text"] as? String {
            text = string
        }
        
        let searchModel = SearchModel(text: text)
        let searchVM = SearchViewModel(model: searchModel)
        let searchEmitter = SearchEmitter(model: searchModel, viewModel: searchVM)
        
        let vc = SearchViewController(searchViewModel: searchVM, searchEmitter: searchEmitter)
        return vc
    }
}
