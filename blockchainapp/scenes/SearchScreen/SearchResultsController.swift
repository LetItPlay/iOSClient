//
//  SearchResultsController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsController: NSObject, UITableViewDelegate, UITableViewDataSource, SearchVMDelegate {
    
    var tableView: UITableView!
    var searchController: UISearchController!
    
    var viewModel: SearchVMProtocol!
    var emitter: SearchEmitterProtocol!
    
    var delegate: SearchControllerDelegate?
    
    weak var parent: UIViewController?
    
    convenience init(viewModel: SearchVMProtocol, emitter: SearchEmitterProtocol) {
        self.init()
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
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
//        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.searchController.isActive = true
        
        self.searchController.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func reloadChannels() {
        self.tableView.reloadData()
    }
    
    func reloadTracks()
    {
        self.tableView.reloadData()
    }
    
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
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.searchController?.searchBar.resignFirstResponder()
//    }
    
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

extension SearchResultsController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            self.emitter.send(event: SearchEvent.searchChanged(string: text))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.close()
    }
}

protocol SearchControllerDelegate {
    func close()
}
