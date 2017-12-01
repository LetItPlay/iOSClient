//
//  MainTabViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 04/09/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import LNPopupController

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let playerVC = AppManager.shared.audioPlayer {
//            view.addSubview(playerVC.view)
//
//            playerVC.view.translatesAutoresizingMaskIntoConstraints = false
//            playerVC.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//            playerVC.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//            playerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -49).isActive = true
//            playerVC.view.heightAnchor.constraint(equalToConstant: 72).isActive = true
			
//			DemoPopupContentViewController* demoVC = [DemoPopupContentViewController new];
//			demoVC.view.backgroundColor = [UIColor redColor];
//			demoVC.popupItem.title = @"Hello World";
//			demoVC.popupItem.subtitle = @"And a subtitle!";
//			demoVC.popupItem.progress = 0.34;
//
//			[self.tabBarController presentPopupBarWithContentViewController:demoVC animated:YES completion:nil];
			
			let vc = PopupController()
			
			vc.popupItem.title = "Hello world! Hello world! "
			vc.popupItem.subtitle = "I love Swift! I love Swift!"
			
			vc.popupItem.progress = 0.34
			vc.popupBar.progressViewStyle = .bottom
			vc.popupItem.image = UIImage.init(named: "channelPrevievImg")
			self.presentPopupBar(withContentViewController: vc, animated: true, completion: nil)
			
			let player = PlayerView.init(frame: CGRect.zero)
			self.popupContentView.addSubview(player)
			
			player.snp.makeConstraints({ (make) in
				make.edges.equalToSuperview()
			})
        }
		
        AppManager.shared.rootTabBarController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedIndex = 2
		
		let nvc = UINavigationController(rootViewController: ProfileViewController.init())
		self.viewControllers?.append(nvc)
    }
}

class MainTabBarDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let nc = viewController as? UINavigationController,
            let _ = nc.viewControllers.first {
            return true
        }
        
        let alertVC = UIAlertController(title: "Currently in development",
                                        message: "",
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        tabBarController.present(alertVC, animated: true, completion: nil)
        
        return false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarController.tabBar.items?[tabBarController.selectedIndex].badgeValue = nil
        if let nc = viewController as? UINavigationController,
            let root = nc.viewControllers.first {
            if root is FeedViewController {
                AppManager.shared.audioPlayer?.showPlayer()
            }
            
            if (root is ChannelsViewController || root is AboutViewController)
                && !AppManager.shared.audioManager.isPlaying {
                AppManager.shared.audioPlayer?.hidePlayer()
            }
        }
    }
    
}
