//
//  ChannelViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 27/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class ChannelViewController: UIViewController {
    
    let tableView = BaseTableView(frame: CGRect.zero, style: .grouped)
    var tableProvider: TableProvider!
    
    var viewModel: ChannelVMProtocol!
    var emitter: ChannelEmitterProtocol!
    
    var header: ChannelHeaderView = ChannelHeaderView()
    
    init(viewModel: ChannelVMProtocol, emitter: ChannelEmitterProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        self.viewModel.channelDelegate = self
        
        self.emitter = emitter
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = { (indexPath, event, data) in
            switch event {
            case "onSelected":
                self.emitter.send(event: TrackEvent.trackSelected(index: indexPath.item))
            case "onOthers":
                self.emitter?.send(event: TrackEvent.showOthers(index: indexPath.row))
            default:
                break
            }
        }
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize()
    {
        self.title = LocalizedStrings.Channels.channel
        
        self.view.backgroundColor = UIColor.white
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.header = ChannelHeaderView(frame: self.view.frame)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.onShared = {
            self.emitter.send(event: ChannelEvent.shareChannel)
        }
        header.onTag = { (tag) in
            self.emitter.send(event: ChannelEvent.tagSelected(tag))
        }
        
        tableView.register(ChannelTrackCell.self, forCellReuseIdentifier: ChannelTrackCell.cellID)
        
        self.header.followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        
        self.tableView.tableHeaderView = self.header
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc func search() {
        self.emitter.send(event: ChannelEvent.showSearch)
    }
    
    @objc func followPressed() {
        self.header.followButton.isSelected = !self.header.followButton.isSelected
        self.emitter.send(event: ChannelEvent.followPressed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.header.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
        }
        
        let height = self.header.fill(channel: self.viewModel.channel!, width: self.view.frame.width)
        self.header.frame.size.height = height
        
        self.emitter.send(event: LifeCycleEvent.appear)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ChannelViewController: TrackHandlingViewModelDelegate {
    func reload(cells: [CollectionUpdate : [Int]]?) {
        tableView.beginUpdates()
        if let keys = cells?.keys {
            for key in keys {
                if let indexes = cells![key]?.map({IndexPath(row: $0, section: 0)}) {
                    switch key {
                    case .insert:
                        tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                    case .delete:
                        tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                    case .update:
                        tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                    }
                }
            }
            tableView.endUpdates()
        }
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    func reloadAppearence() {
        self.header.showOthersButton.isEnabled = !(self.viewModel.channel?.isHidden)!
    }
}

extension ChannelViewController: ChannelVMDelegate {
    
    func updateSubscription() {
        self.header.followButton.set(title: (self.viewModel.channel?.getMainButtonTitle())!)
        self.header.showOthersButton.isEnabled = !(self.viewModel.channel?.isHidden)!
    }
}

extension ChannelViewController: TableDataProvider, TableCellProvider {
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.data[indexPath.item]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return ChannelTrackCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.data.count
    }
    
    func view(table: UITableView, forSection: Int, isHeader: Bool) -> UIView? {
        if isHeader {
            let view = UIView()
            view.backgroundColor = .white
            
            let label = UILabel()
            label.font = AppFont.Title.big
            label.textColor = AppColor.Title.dark
            label.text = LocalizedStrings.Channels.recent
            
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(12)
                make.left.equalToSuperview().inset(16)
            }
            
            return view
        } else {
            return nil
        }
    }
    
    func height(table: UITableView, forSection: Int, isHeader: Bool) -> CGFloat {
        return isHeader ? 53 : 0
    }
}
