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
	var tableView: UITableView = UITableView()
	
	let presenter = SearchPresenter()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Search"
		self.presenter.delegate = self
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .never
		self.view.backgroundColor = .white
		
		self.searchController = UISearchController(searchResultsController:  nil)
		
		self.searchController.searchResultsUpdater = self
		self.searchController.delegate = self
		self.searchController.searchBar.delegate = self
		
		self.searchController.hidesNavigationBarDuringPresentation = false
		self.searchController.dimsBackgroundDuringPresentation = true
//		self.searchController.obscuresBackgroundDuringPresentation = false
		
		self.navigationItem.titleView = self.searchController.searchBar
		
		self.definesPresentationContext = true
		
		self.searchController.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.tableFooterView = nil
		
        // Do any additional setup after loading the view.
		
		self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
		self.presenter.formatPlaylists()
    }
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			self.presenter.searchChanged(string: text)
		}
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.searchController.searchBar.resignFirstResponder()
	}
	
	func updateSearch() {
		self.tableView.reloadData()
	}
	
	func show(state: SearchScreenState) {
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
	
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
			
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			let track = self.presenter.tracks[indexPath.item]
			return SmallTrackTableViewCell.height(text: track.name, width: tableView.frame.width)
		} else {
			return 88.0
		}
	}
}
