//
//  TrackInfoViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class TrackInfoViewController: UIViewController {
    
    var trackInfoHeaderView: TrackInfoHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    convenience init(view: TrackInfoHeaderView) {
        self.init(nibName: nil, bundle: nil)
        self.trackInfoHeaderView = view
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = .white
        
        self.view.addSubview(trackInfoHeaderView)
        trackInfoHeaderView.snp.makeConstraints({ (make) in
            make.top.equalTo(60)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
