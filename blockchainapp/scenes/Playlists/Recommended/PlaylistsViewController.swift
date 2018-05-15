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
    var tableProvider: TableProvider!
    
    var viewModel: PlaylistsVMProtocol!
    var emitter: PlaylistsEmitterProtocol!
    
    let emptyLabel = EmptyLabel(title: "There are no recommendations".localized)
    
    convenience init(playlistViewModel: PlaylistsVMProtocol, playlistEmitter: PlaylistsEmitterProtocol) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = playlistViewModel
        self.viewModel.delegate = self
        
        self.emitter = playlistEmitter
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        
        self.tableProvider.cellEvent = { (indexPath, event, data) in
            switch event {
            case "onSelected":
                AnalyticsEngine.sendEvent(event: .playlistSelected)
                self.emitter.send(event: PlaylistsEvent.formatPlaylists(index: indexPath.row))
            default:
                break
            }
        }
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

extension PlaylistsViewController: TableDataProvider, TableCellProvider {
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.playlists.count
    }
    
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.playlists[indexPath.item]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return PlaylistTableViewCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        
    }
}

//extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.playlists.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.cellID, for: indexPath) as! PlaylistTableViewCell
//        cell.fill(playlist: self.viewModel.playlists[indexPath.item])
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        AnalyticsEngine.sendEvent(event: .playlistSelected)
//        self.emitter.send(event: PlaylistsEvent.formatPlaylists(index: indexPath.row))
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let playlist = self.viewModel.playlists[indexPath.item]
//        return PlaylistTableViewCell.height(title: playlist.title, desc: playlist.description, width: tableView.frame.width)
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }
//}

extension PlaylistsViewController: PlaylistsVMDelegate
{
    func update() {
        self.emptyLabel(hide: self.viewModel.playlists.count == 0 ? false : true)
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
}
