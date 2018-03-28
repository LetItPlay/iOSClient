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
    
    var tableView: UITableView!
    var searchController: UISearchController!
    
    var viewModel: SearchVMProtocol!
    var emitter: SearchEmitterProtocol!
    
    convenience init(searchViewModel: SearchVMProtocol, searchEmitter: SearchEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = searchViewModel
        self.viewModel.delegate = self
        
        self.emitter = searchEmitter
        
        self.tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = nil
        self.tableView.contentInset.bottom = 33
        
        self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
        self.tableView.register(SmallChannelTableViewCell.self, forCellReuseIdentifier: SmallChannelTableViewCell.cellID)
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.view.tintColor = .white
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.definesPresentationContext = true
        
        self.searchController.isActive = true
        
        self.searchController.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.viewInitialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = .white
        
        self.definesPresentationContext = true
        
        self.navigationItem.searchController = self.searchController
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchController.isActive = true
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension SearchViewController: SearchVMDelegate {
    func make(updates: [CollectionUpdate : [Int]]) {
        //        tableView.beginUpdates()
        for key in updates.keys {
            if let indexes = updates[key]?.map({IndexPath(row: $0, section: 0)}) {
                switch key {
                case .insert:
                    tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                case .delete:
                    tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                case .update:
                    //                    var newIndexes: [IndexPath] = []
                    //                    for index in indexes
                    //                    {
                    //                        newIndexes.append(IndexPath(row: index.row, section: 1))
                    //                    }
                    //                    tableView.reloadRows(at: newIndexes, with: UITableViewRowAnimation.none)
                    self.tableView.reloadData()
                }
            }
        }
        //        tableView.endUpdates()
    }
    
    func reloadTracks() {
        self.tableView.reloadData()
    }
    
    func reloadChannels() {
        self.tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.viewModel.channels.count : self.viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath) as! SmallTrackTableViewCell
            cell.fill(vm: self.viewModel.tracks[indexPath.item])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SmallChannelTableViewCell.cellID, for: indexPath) as! SmallChannelTableViewCell
            cell.channel = self.viewModel.channels[indexPath.item]
            cell.onSub = { self.emitter.send(event: SearchEvent.channelSubPressed(index: indexPath.row)) }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.emitter.send(event: SearchEvent.cellDidSelect(section: indexPath.section, index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            let track = self.viewModel.tracks[indexPath.item]
            return Common.height(text: track.name, width: tableView.frame.width)
        } else {
            return SmallChannelTableViewCell.height
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            self.emitter.send(event: SearchEvent.searchChanged(string: text))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
}

