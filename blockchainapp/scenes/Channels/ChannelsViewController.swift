//
//  ChannelsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 23.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.viewInitialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func viewInitialize() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.view.addSubview(view)
        self.view.backgroundColor = .red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
