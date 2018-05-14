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

class CategoryChannelsViewController: UIViewController {
    
    var emitter: CategoryChannelsEmitterProtocol?
    var viewModel: CategoryChannelsViewModel!
    
    var topInset: Bool = false
    
    let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .grouped)
    
    let emptyLabel = EmptyLabel(title: "There are no channels".localized)
    
    convenience init(emitter: CategoryChannelsEmitterProtocol, viewModel: CategoryChannelsViewModel, topInset: Bool)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.topInset = topInset
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.viewInitialize()
        
        self.emitter?.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = self.viewModel.category
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        self.view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.allowsMultipleSelection = true
        
        tableView.contentInset.top = self.topInset ? 44 : 0
        tableView.contentInset.bottom = 72
        
        tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.cellID)
        
        self.view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.center)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        emptyLabel.isHidden = false
        
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

extension CategoryChannelsViewController: CategoryChannelsVMDelegate {
    func updateEmptyMessage() {
        emptyLabel.isHidden = self.viewModel.hideEmptyMessage
    }
    
    func reloadChannels() {
        self.navigationItem.title = self.viewModel.category
        
        if let _: [MediumChannelViewModel] = self.viewModel.channels as? [MediumChannelViewModel] {
            self.tableView.reloadData()
            
            tableView.refreshControl?.endRefreshing()
        }
    }
}

extension CategoryChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.emitter?.send(event: ChannelsEvent.showChannel(index: indexPath.row))
    }
}
