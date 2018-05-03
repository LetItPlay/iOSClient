//
//  MainChannelsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 23.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class MainChannelsViewController: UIViewController {
    
    var viewModel: MainChannelsVMProtocol!
    var emitter: MainChannelsEmitterProtocol?
    
    var channelsView: ChannelsCollectionView!
    let topInset: CGFloat = 44
    
    var tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    convenience init(viewModel: MainChannelsVMProtocol, emitter: MainChannelsEmitterProtocol, channelsView: ChannelsCollectionView) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
        self.channelsView = channelsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
        
        self.emitter?.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        self.tableView.refreshControl?.beginRefreshing()
        
        tableView.contentInset.top = topInset + (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        tableView.contentInset.bottom = 72
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        self.emitter?.send(event: MainChannelsEvent.refresh)
    }
}

extension MainChannelsViewController: MainChannelsVMDelegate {
    func reloadCategories() {
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
}

extension MainChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let contentView = MainChannelsCategoryCellView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 217), category: self.viewModel.categories[indexPath.row])
        
        contentView.onSeeAll = {[weak self] category in
            self?.emitter?.send(event: MainChannelsEvent.showAllChannels(index: indexPath.row))
        }
        contentView.onChannelTap = {[weak self] index in
            self?.emitter?.send(event: MainChannelsEvent.showChannel(index: IndexPath(row: index, section: indexPath.row)))
        }
        
        cell.addSubview(contentView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.channelsView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 117
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 217
    }
}
