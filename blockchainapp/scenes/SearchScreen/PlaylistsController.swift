//
//  PlaylistsController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class PlaylistsController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    var viewModel: PlaylistsVMProtocol!
    var emitter: PlaylistsEmitterProtocol!
    
    let header: UIView = {
        let label = UILabel()
        label.textColor = AppColor.Title.dark
        label.font = AppFont.Title.section
        label.text = "Today playlists".localized
        
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
    }()
    
    convenience init(viewModel: PlaylistsVMProtocol, emitter: PlaylistsEmitterProtocol)
    {
        self.init()
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
        self.commonInit()
        
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
//        self.tableView.refreshControl = refreshControl
//        refreshControl.beginRefreshing()
    }
    
    func commonInit()
    {
        self.tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
//    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
////        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {[weak self] in self?.emitter.send(event: PlaylistsEvent.refresh)})
////        self.emitter.send(event: PlaylistsEvent.refresh)
//    }
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if self.tableView.refreshControl?.isRefreshing == true {
//            self.emitter.send(event: PlaylistsEvent.refresh)
//        }
	}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.cellID, for: indexPath) as! PlaylistTableViewCell
        cell.fill(playlist: self.viewModel.playlists[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsEngine.sendEvent(event: .searchEvent(event: .playlistTapped))
        self.emitter.send(event: PlaylistsEvent.formatPlaylists(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let playlist = self.viewModel.playlists[indexPath.item]
        return PlaylistTableViewCell.height(title: playlist.title, desc: playlist.description, width: tableView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 41
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
	
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.viewModel.playlists.count == 0 {
            return nil
        }
		
		return header
    }
}

extension PlaylistsController: PlaylistsVMDelegate
{
    func update() {
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
}
