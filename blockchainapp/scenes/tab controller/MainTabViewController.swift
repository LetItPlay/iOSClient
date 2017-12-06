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
	
	let vc = PopupController()
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
		
		let tabs: [String: (UIImage?, UIViewController)] = [
			"Feed": (nil, FeedBuilder.build()),
			"Trends": (nil, PopularBuilder.build()),
			"Channels": (nil, ChannelsBuilder.build())]
		
		self.viewControllers = tabs.map({ (tuple) -> UINavigationController in
			let nvc = UINavigationController(rootViewController: tuple.value.1)
			nvc.tabBarItem = UITabBarItem(title: tuple.key, image: tuple.value.0, tag: 0)
			return nvc
		})
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
			
		self.presentPopupBar(withContentViewController: vc, animated: true, completion: nil)
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
