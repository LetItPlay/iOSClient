//
//  TrackInfoViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class TrackInfoViewController: UIViewController {
    
    // for comments
//    var _tableView: UITableView = UITableView()
    
    var trackInfo: TrackInfoHeaderView!
    
    var track: TrackViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    convenience init(view: TrackInfoHeaderView) {
        self.init(nibName: nil, bundle: nil)
        self.trackInfo = view
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = .white
        
        self.view.addSubview(trackInfo)
        trackInfo.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
//        self.view.addSubview(_tableView)
//        _tableView.snp.makeConstraints({ (make) in
//            make.edges.equalToSuperview()
//        })
//
//        _tableView.delegate = self
//        _tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(_ track: TrackViewModel)
    {
        self.track = track
    }

}

//extension TrackInfoViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return UITableViewCell()
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return TrackInfoHeaderView()
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 1500
//    }
//}

