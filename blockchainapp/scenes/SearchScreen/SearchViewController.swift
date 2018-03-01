//
//  SearchViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 13/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class Custom: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .red
	}
}

class SearchViewController: UIViewController,
UISearchControllerDelegate,
UISearchBarDelegate {

    var searchController: UISearchController!
	var searchResultsTableView: UITableView = UITableView()
	var playlistTableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
	
    var searchResults = SearchResultsController()
    var playlistsResults: PlaylistsController!
	
	var emptyLabel: UIView!
    
    convenience init(playlistViewModel: PlaylistsVMProtocol, playlistEmitter: PlaylistsEmitterProtocol, searchViewModel: SearchVMProtocol, searchEmitter: SearchEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.playlistsResults = PlaylistsController(viewModel: playlistViewModel, emitter: playlistEmitter)
        self.playlistTableView = self.playlistsResults.tableView
        
        self.searchResults = SearchResultsController(viewModel: searchViewModel, emitter: searchEmitter)
        self.searchResultsTableView = self.searchResults.tableView
        self.searchController = self.searchResults.searchController
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Search".localized
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .always
		self.view.backgroundColor = .white
        
		self.definesPresentationContext = true

		self.navigationItem.searchController = self.searchController
		
		self.view.addSubview(playlistTableView)
		playlistTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
		}
        
        playlistTableView.contentInset.bottom = 40
		playlistTableView.delegate = self.playlistsResults
		playlistTableView.dataSource = self.playlistsResults
		
		playlistTableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.cellID)
		playlistTableView.separatorStyle = .none
		playlistTableView.backgroundColor = .white
		
		self.navigationItem.hidesSearchBarWhenScrolling = false
        
        let label = UILabel()
        label.textColor = AppColor.Title.dark
        label.font = AppFont.Title.big
        label.text = "There are no playlists".localized
        
        self.view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).inset(self.view.frame.height / 2 + 50)
            make.centerX.equalToSuperview()
        }
		
		self.emptyLabel = label
        
        self.emptyLabel.isHidden = self.playlistsResults.viewModel.playlists.count != 0
        
        self.playlistsResults.emitter.send(event: LifeCycleEvent.initialize)
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
