//
//  PlaylistsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 28.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    var tableView = UITableView()
    
    var viewModel: PlaylistsVMProtocol!
    var emitter: PlaylistsEmitterProtocol!
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.sectionNotBold
        label.textColor = AppColor.Element.emptyMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "There are no recommendations".localized
        return label
    }()
    
    convenience init(playlistViewModel: PlaylistsVMProtocol, playlistEmitter: PlaylistsEmitterProtocol) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = playlistViewModel
        self.viewModel.delegate = self
        
        self.emitter = playlistEmitter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        
        self.view.backgroundColor = .white
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.tableView.contentInset.top = 44
        self.tableView.contentInset.bottom = 40
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.cellID)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .white
        self.tableView.setContentOffset(CGPoint.zero, animated: true)

        self.view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.center)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }

        self.emptyLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func emptyLabel(hide: Bool) {
        self.emptyLabel.isHidden = hide
    }
    
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        self.emitter.send(event: .refresh)
    }
}

extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension PlaylistsViewController: PlaylistsVMDelegate
{
    func update() {
        self.emptyLabel(hide: self.viewModel.playlists.count == 0 ? false : true)
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
}
