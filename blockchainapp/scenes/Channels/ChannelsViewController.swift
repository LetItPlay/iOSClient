//
//  ChannelsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 23.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 250))
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        button.setTitleColor(.black, for: .normal)
        button.setTitle("PUSH ME", for: .normal)
        button.addTarget(self, action: #selector(self.pushed), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func pushed() {
        self.view.backgroundColor = .orange
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
