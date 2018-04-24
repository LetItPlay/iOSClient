//
//  ChannelsSegmentViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 23.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelsSegmentViewController: UIViewController {
    
    var channelsSegmentedControl: UISegmentedControl = UISegmentedControl(items: ["Categories", "Recent added"])
    var contentView: UIView = UIView()
    var views: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewInitialize()
    }
    
    func viewInitialize() {
        self.view.backgroundColor = AppColor.Element.backgroundColor
        
        channelsSegmentedControl.selectedSegmentIndex = 0
        channelsSegmentedControl.tintColor = AppColor.Element.redBlur.withAlphaComponent(1)
        channelsSegmentedControl.addTarget(self, action: #selector(self.changeScreen(sender:)), for: .valueChanged)
        
        self.view.addSubview(channelsSegmentedControl)
        channelsSegmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(72)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(28)
        }
        
        let line = UIView()
        line.backgroundColor = AppColor.Element.redBlur
        self.view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.equalTo(channelsSegmentedControl.snp.bottom).inset(-8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.view.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(channelsSegmentedControl.snp.bottom).inset(-8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let first = ChannelsViewController()
        self.views.append(first.view)
    }
    
    @objc func changeScreen(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            contentView.backgroundColor = .brown
        case 1:
            self.contentView = self.views[0]
        default:
            print("you forgot something")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
