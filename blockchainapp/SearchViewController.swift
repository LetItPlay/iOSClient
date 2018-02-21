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
//UISearchResultsUpdating,
UISearchBarDelegate {//,
//SearchPresenterDelegate {

    var searchController: UISearchController!
	var searchResultsTableView: UITableView = UITableView()
	var playlistTableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
	
	let presenter = SearchPresenter()
	
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
        
//        self.searchController.hidesNavigationBarDuringPresentation = true
//        self.searchController.dimsBackgroundDuringPresentation = true
        
//        self.searchController.view.addSubview(searchResultsTableView)
//        searchResultsTableView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Search".localized
//        self.presenter.delegate = self
		
//        self.searchResults.presenter = self.presenter
//        self.searchResults.searchController = self.searchController
//        self.searchResults.parent = self
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .always
		self.view.backgroundColor = .white
		
//        self.searchController = UISearchController(searchResultsController:  nil)
//
//        self.searchController.searchResultsUpdater = self
//        self.searchController.delegate = self
//        self.searchController.searchBar.delegate = self
//
//        self.searchController.hidesNavigationBarDuringPresentation = true
//        self.searchController.dimsBackgroundDuringPresentation = true
		self.definesPresentationContext = true

		self.navigationItem.searchController = self.searchController
		
//        self.searchController.view.addSubview(searchResultsTableView)
//        searchResultsTableView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
		
//        self.searchResultsTableView.delegate = self.searchResults
//        self.searchResultsTableView.dataSource = self.searchResults
//        self.searchResultsTableView.tableFooterView = nil
		
        // Do any additional setup after loading the view.
		
//        self.searchResultsTableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
//        self.searchResultsTableView.register(SmallChannelTableViewCell.self, forCellReuseIdentifier: SmallChannelTableViewCell.cellID)
//		self.presenter.formatPlaylists()
		
		
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
		
		self.emptyLabel.isHidden = self.presenter.playlists.count != 0
        
        self.playlistsResults.emitter.send(event: LifeCycleEvent.initialize)
    }
	
//    func updateSearchResults(for searchController: UISearchController) {
//        if let text = searchController.searchBar.text {
//            self.presenter.searchChanged(string: text)
//        }
//    }
	
//    func updateSearch() {
//        self.searchResultsTableView.reloadData()
//    }
//
//    func update(tracks: [Int], channels: [Int]) {
//        self.searchResultsTableView.reloadRows(at: tracks.map({IndexPath.init(row: $0, section: 1)}), with: .none)
//        self.searchResultsTableView.reloadRows(at: channels.map({IndexPath.init(row: $0, section: 0)}), with: .none)
//    }
//
//    func updatePlaylists() {
//        self.playlistTableView.reloadData()
//        self.emptyLabel.isHidden = self.presenter.playlists.count != 0
//    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		
//        self.presenter.getData()
		
//        if self.presenter.currentSearchString != "" {
//            AnalyticsEngine.sendEvent(event: .searchEvent(event: .search(text: self.presenter.currentSearchString)))
//        }
    }
}
