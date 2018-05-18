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
    
    var tableView = BaseTableView(frame: CGRect.zero, style: .grouped)
    var tableProvider: TableProvider!
    
    convenience init(viewModel: MainChannelsVMProtocol, emitter: MainChannelsEmitterProtocol, channelsView: ChannelsCollectionView) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
        self.channelsView = channelsView
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = { (indexPath, event, data) in
            switch event {
            case "onSeeAll":
                self.emitter?.send(event: MainChannelsEvent.showAllChannels(index: indexPath.row))
            case "onChannelTap":
                if let _ = data, let item = data!["item"] {
                    self.emitter?.send(event: MainChannelsEvent.showChannel(index: IndexPath(row: item as! Int, section: indexPath.row)))
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
    
    func viewInitialize() {
        tableView.register(MainChannelsTableViewCell.self, forCellReuseIdentifier: MainChannelsTableViewCell.cellID)
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        self.tableView.refreshControl?.beginRefreshing()
        
        tableView.contentInset.top = topInset + (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        
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

extension MainChannelsViewController: TableDataProvider, TableCellProvider {
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.categories[indexPath.item]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return MainChannelsTableViewCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.categories.count
    }
    
    func view(table: UITableView, forSection: Int, isHeader: Bool) -> UIView? {
        return isHeader ? self.channelsView : nil
    }
    
    func height(table: UITableView, forSection: Int, isHeader: Bool) -> CGFloat {
        return isHeader ? 117 : 0
    }
}
