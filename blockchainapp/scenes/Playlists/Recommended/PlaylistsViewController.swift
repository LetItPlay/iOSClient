//
//  PlaylistsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 28.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    var playlistsResults: PlaylistsController!
    
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
        
        self.playlistsResults = PlaylistsController(viewModel: playlistViewModel, emitter: playlistEmitter)
        self.playlistsResults.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewInitialize()
        
        self.playlistsResults.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.playlistsResults.tableView)
        self.playlistsResults.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.playlistsResults.tableView.contentInset.bottom = 40
        self.playlistsResults.tableView.delegate = self.playlistsResults
        self.playlistsResults.tableView.dataSource = self.playlistsResults

        self.playlistsResults.tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.cellID)
        self.playlistsResults.tableView.separatorStyle = .none
        self.playlistsResults.tableView.backgroundColor = .white

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
//        self.playlistsResults.tableView.setContentOffset(CGPoint.zero, animated: false)
    }
}

extension PlaylistsViewController: PlaylistsDelegate {
    func emptyLabel(hide: Bool) {
        self.emptyLabel.isHidden = hide
//        self.playlistsResults.tableView.setContentOffset(CGPoint.zero, animated: false)
    }
}
