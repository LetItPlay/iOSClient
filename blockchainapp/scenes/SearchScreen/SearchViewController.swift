//
//  SearchViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 13/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

protocol SearchViewControllerDelegate {
    func searchDidDisappear()
}

class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    let tableView = BaseTableView(frame: CGRect.zero, style: .grouped)
    var tableProvider: TableProvider!
    
    var searchController: UISearchController!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var viewModel: SearchVMProtocol!
    var emitter: SearchEmitterProtocol!
    
    var delegate: SearchViewControllerDelegate?
    
    convenience init(searchViewModel: SearchVMProtocol, searchEmitter: SearchEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = searchViewModel
        self.viewModel.delegate = self
        
        self.emitter = searchEmitter
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = {(indexPath, event, data) in
            switch event {
            case "onSelected":
                self.searchController.searchBar.resignFirstResponder()
                self.emitter.send(event: SearchEvent.cellDidSelect(section: indexPath.section, index: indexPath.row))
            case "onOthers":
                self.emitter.send(event: SearchEvent.showOthers(index: indexPath.row))
            case "onFollow":
                self.emitter.send(event: SearchEvent.channelSubPressed(index: indexPath.row))
            default:
                break
            }
        }
        self.tableProvider.cellShowed = { (indexPath) in
            if indexPath.section == 1 && indexPath.row == self.viewModel.tracks.count - 1, !self.viewModel.nothingToUpdate {
                self.activityIndicator.startAnimating()
                self.emitter.send(event: SearchEvent.showMoreTracks)
            }
        }
        self.tableProvider.beginDragging = {(scrollView) in
            self.searchController.searchBar.resignFirstResponder()
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.viewInitialize()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.navigationItem.hidesBackButton = true
        
        self.view.backgroundColor = .white
        
        self.tableView.tableFooterView = nil
        
        self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
        self.tableView.register(SmallChannelTableViewCell.self, forCellReuseIdentifier: SmallChannelTableViewCell.cellID)
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.view.tintColor = .white
        
        self.searchController.dimsBackgroundDuringPresentation = true
		
        self.searchController.isActive = true
        
        self.searchController.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.definesPresentationContext = true
        
        self.navigationItem.searchController = self.searchController
        
        self.searchController.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.view.setNeedsLayout()
        self.navigationController?.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.searchDidDisappear()
    }
}

extension SearchViewController: SearchVMDelegate {
    
    func set(text: String) {
        self.searchController.searchBar.text = text
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
    
    func reloadTracks() {
        self.tableView.reloadData()
        activityIndicator.stopAnimating()
    }
    
    func reloadChannels() {
        self.tableView.reloadData()
    }
}

extension SearchViewController: TableCellProvider, TableDataProvider {
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        if indexPath.section == 0 {
            return SmallChannelTableViewCell.self
        } else {
            return SmallTrackTableViewCell.self
        }
    }
    
    func config(cell: StandartTableViewCell) {
        
    }
    
    func data(indexPath: IndexPath) -> Any {
        if indexPath.section == 0 {
            return self.viewModel.channels[indexPath.item]
        } else {
            return self.viewModel.tracks[indexPath.item]
        }
    }
    
    var numberOfSections: Int {
        return 2
    }
    
    func rowsAt(_ section: Int) -> Int {
        return section == 0 ? self.viewModel.channels.count : self.viewModel.tracks.count
    }
    
    func view(table: UITableView, forSection: Int, isHeader: Bool) -> UIView? {
        if !isHeader {
            return activityIndicator
        } else {
            return nil
        }
    }
}

//extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return section == 0 ? self.viewModel.channels.count : self.viewModel.tracks.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section != 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath) as! SmallTrackTableViewCell
//            cell.fill(vm: self.viewModel.tracks[indexPath.item])
//            cell.onOthers = {[weak self] in
//                self?.emitter.send(event: SearchEvent.showOthers(index: indexPath.row))
//            }
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: SmallChannelTableViewCell.cellID, for: indexPath) as! SmallChannelTableViewCell
//            cell.channel = self.viewModel.channels[indexPath.item]
//            cell.onSub = { self.emitter.send(event: SearchEvent.channelSubPressed(index: indexPath.row)) }
//            return cell
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.searchController.searchBar.resignFirstResponder()
//        self.emitter.send(event: SearchEvent.cellDidSelect(section: indexPath.section, index: indexPath.row))
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 1 {
//            let track = self.viewModel.tracks[indexPath.item]
//            return Common.height(text: track.name, width: tableView.frame.width)
//        } else {
//            return SmallChannelTableViewCell.height
//        }
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 && indexPath.row == self.viewModel.tracks.count - 1,
//            !viewModel.nothingToUpdate {
//                activityIndicator.startAnimating()
//                self.emitter.send(event: SearchEvent.showMoreTracks)
//        }
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 0 {
//            return nil
//        } else {
//            return activityIndicator
//        }
//    }
//}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            self.emitter.send(event: SearchEvent.searchChanged(string: text))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
}
