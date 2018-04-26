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
    
    var channelsView: ChannelsCollectionView!
    let topInset = 44
    
    var scrollView = UIScrollView()
    
    convenience init(channelsView: ChannelsCollectionView) {
        self.init(nibName: nil, bundle: nil)
        
        self.channelsView = channelsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(channelsView)
        channelsView.snp.makeConstraints { (make) in
            make.top.equalTo(topInset + 20)
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            make.height.equalTo(117)
        }
    }
}
