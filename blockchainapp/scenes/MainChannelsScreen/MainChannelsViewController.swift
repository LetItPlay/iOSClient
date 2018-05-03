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
    
    var channelsView: ChannelsCollectionView!
    let topInset = 44
    
    var tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    convenience init(viewModel: MainChannelsVMProtocol, channelsView: ChannelsCollectionView) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.channelsView = channelsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset.top = 44
        tableView.contentInset.bottom = 72
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension MainChannelsViewController: MainChannelsVMDelegate {
    func reloadCategories() {
        self.tableView.reloadData()
    }
}

extension MainChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let keys = self.viewModel.categories.keys.map({$0})
        cell.textLabel?.text = keys[indexPath.row]
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
