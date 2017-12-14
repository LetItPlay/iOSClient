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
UISearchResultsUpdating,
UISearchBarDelegate,
SearchPresenterDelegate {

	var searchController: UISearchController!
	var searchResultsTableView: UITableView = UITableView()
	var playlistTableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
	
	let presenter = SearchPresenter()
	
	let searchResults = SearchResultsController()
	let playlistsResults = PlaylistsController()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Search"
		self.presenter.delegate = self
		
		self.searchResults.presenter = self.presenter
		self.searchResults.searchController = self.searchController
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .always
		self.view.backgroundColor = .white
		
		self.searchController = UISearchController(searchResultsController:  nil)
		
		self.searchController.searchResultsUpdater = self
		self.searchController.delegate = self
		self.searchController.searchBar.delegate = self
		
		self.searchController.hidesNavigationBarDuringPresentation = true
		self.searchController.dimsBackgroundDuringPresentation = true
		self.definesPresentationContext = true

		self.navigationItem.searchController = self.searchController
		
		self.searchController.view.addSubview(searchResultsTableView)
		searchResultsTableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		self.searchResultsTableView.delegate = self.searchResults
		self.searchResultsTableView.dataSource = self.searchResults
		self.searchResultsTableView.tableFooterView = nil
		
        // Do any additional setup after loading the view.
		
		self.searchResultsTableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
		self.searchResultsTableView.register(SmallChannelTableViewCell.self, forCellReuseIdentifier: SmallChannelTableViewCell.cellID)
//		self.presenter.formatPlaylists()
		
		
		self.view.addSubview(playlistTableView)
		playlistTableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		playlistTableView.delegate = self.playlistsResults
		playlistTableView.dataSource = self.playlistsResults
		
		playlistTableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.cellID)
		playlistTableView.separatorStyle = .none
		playlistTableView.backgroundColor = .white
		
		self.navigationItem.hidesSearchBarWhenScrolling = false
    }
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			self.presenter.searchChanged(string: text)
		}
	}
	
	func updateSearch() {
		self.searchResultsTableView.reloadData()
	}

}

class PlaylistsController: NSObject, UITableViewDelegate, UITableViewDataSource {
	weak var presenter: SearchPresenter!

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.cellID, for: indexPath)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return PlaylistTableViewCell.height(title: "123", desc: "123\n123", width: tableView.frame.width)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 41
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.textColor = AppColor.Title.dark
		label.font = AppFont.Title.section
		label.text = "Today playlists"
		
		let container = UIView()
		container.backgroundColor = UIColor.white
		container.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
		return container
	}
}

class SearchResultsController: NSObject, UITableViewDelegate, UITableViewDataSource {

	weak var presenter: SearchPresenter!
	weak var searchController: UISearchController?
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.searchController?.searchBar.resignFirstResponder()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? self.presenter.channels.count : self.presenter.tracks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section != 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath) as! SmallTrackTableViewCell
			cell.track = self.presenter.tracks[indexPath.item]
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: SmallChannelTableViewCell.cellID, for: indexPath)
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 1 {
			let track = self.presenter.tracks[indexPath.item]
			return SmallTrackTableViewCell.height(text: track.name, width: tableView.frame.width)
		} else {
			return SmallChannelTableViewCell.height
		}
	}
}
