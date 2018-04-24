//
//  PlaylistsSegmentedViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 24.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class PlaylistsSegmentedViewController: UIViewController {
    
    var playlistsSegmentedControll: UISegmentedControl = UISegmentedControl(items: ["My playlist".localized, "Recommended".localized])
    
    let firstViewController = UserPlaylistBuilder.build(params: nil)
    let secondViewController = PlaylistsBuilder.build(params: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewInitialize()
    }
    
    func viewInitialize() {
        self.view.backgroundColor = .white
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addChildViewController(firstViewController!)
        firstViewController?.view.frame = self.view.frame
        self.view.addSubview((firstViewController?.view)!)
        firstViewController?.didMove(toParentViewController: self)
        
        self.addChildViewController(secondViewController!)
        secondViewController!.view.frame = self.view.frame
        self.view.addSubview((secondViewController?.view)!)
        
        self.hide(first: false)
        
        playlistsSegmentedControll.selectedSegmentIndex = 0
        playlistsSegmentedControll.tintColor = AppColor.Element.redBlur.withAlphaComponent(1)
        playlistsSegmentedControll.addTarget(self, action: #selector(self.changeScreen(sender:)), for: .valueChanged)
        
        var blurView = UIVisualEffectView()
        blurView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.clipsToBounds = true
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        blurView.contentView.addSubview(playlistsSegmentedControll)
        playlistsSegmentedControll.snp.makeConstraints { (make) in
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
            make.bottom.equalTo(playlistsSegmentedControll.snp.bottom).inset(-8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func hide(first: Bool) {
        firstViewController?.view.isHidden = first
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
}
