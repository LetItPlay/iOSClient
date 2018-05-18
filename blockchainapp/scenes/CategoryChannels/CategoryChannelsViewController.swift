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
    
    let tableView = BaseTableView(frame: CGRect.zero, style: .grouped)
    var tableProvider: TableProvider!
    
    let emptyLabel = EmptyLabel(title: LocalizedStrings.EmptyMessage.noChannels)
    
    convenience init(emitter: CategoryChannelsEmitterProtocol, viewModel: CategoryChannelsViewModel, topInset: Bool)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.topInset = topInset
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = {(indexPath, event, data) in
            switch event {
            case "onSelected":
                self.emitter?.send(event: ChannelsEvent.showChannel(index: indexPath.row))
            case "onFollow":
                self.emitter?.send(event: ChannelsEvent.subscribe(index: indexPath.item))
            case "onTag":
                if let _ = data, let text = data!["text"] as? String {
                    self.emitter?.send(event: ChannelsEvent.tagSelected(text))
                }
            default:
                break
            }
        }
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
        
        self.tableView.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        self.view.backgroundColor = .white
        
        tableView.allowsMultipleSelection = true
        
        tableView.contentInset.top = self.topInset ? 44 : 0
        tableView.separatorStyle = .singleLine
        
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

extension CategoryChannelsViewController: TableDataProvider, TableCellProvider {
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.channels[indexPath.row]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return ChannelTableViewCell.self
    }
    
    func config(cell: StandartTableViewCell) {
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.channels.count
    }
}

//extension CategoryChannelsViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.channels.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.cellID, for: indexPath) as! ChannelTableViewCell
//        let channel = self.viewModel.channels[indexPath.row] as! MediumChannelViewModel
//        cell.channel = channel
//        cell.subAction = {[weak self] channel in
//            if let _ = channel {
//                self?.emitter?.send(event: ChannelsEvent.subscribe(index: indexPath.item))
//            }
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return ChannelTableViewCell.height
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return ChannelTableViewCell.height
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.emitter?.send(event: ChannelsEvent.showChannel(index: indexPath.row))
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
//}
