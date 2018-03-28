//
//  PlaylistsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 28.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PlaylistsViewController: UIViewController {
    
    var itemInfo = IndicatorInfo(title: "View")
    
    var playlistsResults: PlaylistsController!
    var emptyLabel: UIView!
    
    convenience init(playlistViewModel: PlaylistsVMProtocol, playlistEmitter: PlaylistsEmitterProtocol) {
        self.init(nibName: nil, bundle: nil)
        
        self.playlistsResults = PlaylistsController(viewModel: playlistViewModel, emitter: playlistEmitter)
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

        let label = UILabel()
        label.textColor = AppColor.Title.dark
        label.font = AppFont.Title.big
        label.text = "There are no playlists".localized

        self.view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).inset(self.view.frame.height / 2 + 50)
            make.centerX.equalToSuperview()
        }

        self.emptyLabel = label

        self.emptyLabel.isHidden = self.playlistsResults.viewModel.playlists.count != 0
    }

}

extension PlaylistsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
