//
//  PlaylistsController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 15.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class PlaylistsController: NSObject, UITableViewDelegate, UITableViewDataSource, PlaylistsVMDelegate {
    
    var tableView: UITableView!
    
    var playlists: [PlaylistViewModel] = []
    
    var viewModel: PlaylistsVMProtocol!
    var emitter: PlaylistsEmitterProtocol!
    
    
    func update() {
        self.playlists = self.viewModel.playlists
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    convenience init(viewModel: PlaylistsVMProtocol, emitter: PlaylistsEmitterProtocol)
    {
        self.init()
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
        self.tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        print("REFRESH")
        self.emitter.send(event: PlaylistsEvent.refresh)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.cellID, for: indexPath) as! PlaylistTableViewCell
        cell.fill(playlist: playlists[indexPath.item])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.emitter.send(event: PlaylistsEvent.formatPlaylists(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let playlist = self.playlists[indexPath.item]
        return PlaylistTableViewCell.height(title: playlist.title, desc: playlist.description, width: tableView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 41
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.playlists.count == 0 {
            return nil
        }
        
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
    }
}
