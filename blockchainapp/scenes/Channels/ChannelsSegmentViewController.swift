//
//  ChannelsSegmentViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 23.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelsSegmentViewController: UIViewController {
    
    var channelsSegmentedControl: UISegmentedControl = UISegmentedControl(items: ["Categories".localized, "Recent added".localized])
    
    let firstViewController = UIViewController() //ChannelsViewController(nibName: nil, bundle: nil)
    let secondViewController = CategoryChannelsBuilder.build(params: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        self.view.backgroundColor = .white
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addChildViewController(firstViewController)
        firstViewController.view.frame = self.view.frame
        self.view.addSubview(firstViewController.view)
        firstViewController.didMove(toParentViewController: self)
        
        self.addChildViewController(secondViewController!)
        secondViewController!.view.frame = self.view.frame
        self.view.addSubview((secondViewController?.view)!)
        
        self.hide(first: false)
        
        channelsSegmentedControl.selectedSegmentIndex = 0
        channelsSegmentedControl.tintColor = AppColor.Element.redBlur.withAlphaComponent(1)
        channelsSegmentedControl.addTarget(self, action: #selector(self.changeScreen(sender:)), for: .valueChanged)
        
        var blurView = UIVisualEffectView()
        blurView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.clipsToBounds = true
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        blurView.contentView.addSubview(channelsSegmentedControl)
        channelsSegmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(28)
        }
        
        self.view.addSubview(blurView)
        blurView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(64)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
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
    }
    
    func hide(first: Bool) {
        firstViewController.view.isHidden = first
        secondViewController?.view.isHidden = !first
    }
    
    @objc func changeScreen(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.hide(first: false)
        case 1:
            self.hide(first: true)
        default:
            print("you forgot something")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
