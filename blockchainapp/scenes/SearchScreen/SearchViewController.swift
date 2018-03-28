//
//  SearchViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 13/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {

    var searchController: UISearchController!
	
    var searchResults = SearchResultsController()

    convenience init(searchViewModel: SearchVMProtocol, searchEmitter: SearchEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.searchResults = SearchResultsController(viewModel: searchViewModel, emitter: searchEmitter)
        self.searchController = self.searchResults.searchController
        self.searchResults.delegate = self
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.viewInitialize()
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = .white
        
        self.definesPresentationContext = true
        
        self.navigationItem.searchController = self.searchController
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchResults.searchController.isActive = true
        self.searchResults.searchController.searchBar.becomeFirstResponder()
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension SearchViewController: SearchControllerDelegate {
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}
