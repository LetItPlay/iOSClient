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
//    var playlistsResults: PlaylistsController!
    
//    var emptyLabel: UIView!
    
//    convenience init(playlistViewModel: PlaylistsVMProtocol, playlistEmitter: PlaylistsEmitterProtocol, searchViewModel: SearchVMProtocol, searchEmitter: SearchEmitterProtocol)
    convenience init(searchViewModel: SearchVMProtocol, searchEmitter: SearchEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
//        self.playlistsResults = PlaylistsController(viewModel: playlistViewModel, emitter: playlistEmitter)
        
        self.searchResults = SearchResultsController(viewModel: searchViewModel, emitter: searchEmitter)
        self.searchController = self.searchResults.searchController
        self.searchResults.delegate = self
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.viewInitialize()
        
//        self.playlistsResults.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
//        self.title = "Search".localized
        
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationItem.largeTitleDisplayMode = .always
        self.view.backgroundColor = .white
        
        self.definesPresentationContext = true
        
        self.navigationItem.searchController = self.searchController
        
//        self.view.addSubview(self.playlistsResults.tableView)
//        self.playlistsResults.tableView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
//        self.playlistsResults.tableView.contentInset.bottom = 40
//        self.playlistsResults.tableView.delegate = self.playlistsResults
//        self.playlistsResults.tableView.dataSource = self.playlistsResults
//
//        self.playlistsResults.tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.cellID)
//        self.playlistsResults.tableView.separatorStyle = .none
//        self.playlistsResults.tableView.backgroundColor = .white
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchResults.searchController.isActive = true
        self.searchResults.searchController.searchBar.becomeFirstResponder()
        
//        let label = UILabel()
//        label.textColor = AppColor.Title.dark
//        label.font = AppFont.Title.big
//        label.text = "There are no playlists".localized
        
//        self.view.addSubview(label)
//        label.snp.makeConstraints { (make) in
//            make.top.equalTo(self.view).inset(self.view.frame.height / 2 + 50)
//            make.centerX.equalToSuperview()
//        }
        
//        self.emptyLabel = label
        
//        self.emptyLabel.isHidden = self.playlistsResults.viewModel.playlists.count != 0
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
