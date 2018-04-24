//
//  CategoryChannelsViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SDWebImage
import TagListView

class CategoryChannelsViewController: UITableViewController {
    
    var emitter: ChannelsEmitterProtocol?
    var viewModel: ChannelsViewModel!
    
    convenience init(emitter: ChannelsEmitterProtocol, viewModel: ChannelsViewModel)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.viewInitialize()
        
        self.emitter?.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {

        navigationController?.navigationBar.prefersLargeTitles = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        self.view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.allowsMultipleSelection = true
        tableView.refreshControl = refreshControl
        
        tableView.contentInset.bottom = 72
        
        tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.cellID)
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc func search() {
        self.emitter?.send(event: ChannelsEvent.showSearch)
    }
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emitter?.send(event: LifeCycleEvent.appear)
		self.tableView.reloadData()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emitter?.send(event: LifeCycleEvent.disappear)
    }
    
    deinit {
        self.emitter?.send(event: LifeCycleEvent.deinitialize)
    }
    
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        self.emitter?.send(event: ChannelsEvent.refreshData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CategoryChannelsViewController: ChannelsVMDelegate {
    func reloadChannels() {
        if let _: [MediumChannelViewModel] = self.viewModel.channels as? [MediumChannelViewModel] {
//            self.source = source
            self.tableView.reloadData()
            
            refreshControl?.endRefreshing()
        }
    }
}

extension CategoryChannelsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.cellID, for: indexPath) as! ChannelTableViewCell
        let channel = self.viewModel.channels[indexPath.row] as! MediumChannelViewModel
        cell.channel = channel
        cell.subAction = {[weak self] channel in
            if let _ = channel {
                self?.emitter?.send(event: ChannelsEvent.subscribe(index: indexPath.item))
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelTableViewCell.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelTableViewCell.height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsEngine.sendEvent(event: .channelCellTapped)
        self.emitter?.send(event: ChannelsEvent.showChannel(index: indexPath.row))
    }
}
