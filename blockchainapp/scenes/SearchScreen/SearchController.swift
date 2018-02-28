//
//  SearchController.swift
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
    
    var tracks: [TrackViewModel] = []
    var channels: [SearchChannelViewModel] = []
    
    var viewModel: SearchVMProtocol!
    var emitter: SearchEmitterProtocol!
    
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
        
        self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
        self.tableView.register(SmallChannelTableViewCell.self, forCellReuseIdentifier: SmallChannelTableViewCell.cellID)
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.searchController.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func update(data: ViewModels) {
        switch data {
        case .channels:
            self.channels = self.viewModel.channels
        case .tracks:
            self.tracks = self.viewModel.tracks
        }
        self.tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController?.searchBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.channels.count : self.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath) as! SmallTrackTableViewCell
            
            let _ = self.viewModel.currentPlayingIndex == indexPath.item
            //            cell.dataLabels[.listens]?.isHidden = isPlaying
            //            cell.dataLabels[.playingIndicator]?.isHidden = !isPlaying
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SmallChannelTableViewCell.cellID, for: indexPath) as! SmallChannelTableViewCell
            cell.channel = self.channels[indexPath.item]
            cell.onSub = { self.emitter.send(event: SearchEvent.channelSubPressed(index: indexPath.row)) }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            AnalyticsEngine.sendEvent(event: .searchEvent(event: .channelTapped))
        } else {
            AnalyticsEngine.sendEvent(event: .searchEvent(event: .trackTapped))
        }
        
        self.emitter.send(event: SearchEvent.cellDidSelect(section: indexPath.section, index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            let track = self.tracks[indexPath.item]
            return SmallTrackTableViewCell.height(text: track.name, width: tableView.frame.width)
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
    
}
