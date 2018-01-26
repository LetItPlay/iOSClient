//
//  MainTabViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 04/09/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController, AudioControllerPresenter, MiniPlayerPresentationDelegate {
		
	let playerController = PlayerViewController()
	let miniPlayer = MiniPlayerView()
	var miniPlayerBottomConstr: NSLayoutConstraint?
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
		
		let tabs: [(String, (UIImage?, UIViewController))] = [
			("Feed".localized, (UIImage.init(named: "feedTab"), FeedBuilder.build())),
			("Trends".localized, (UIImage.init(named: "trendsTab"), PopularBuilder.build())),
			("Search".localized, (UIImage.init(named: "searchTab"), SearchViewController())),
			("Channels".localized, (UIImage.init(named: "channelsTab"), ChannelsBuilder.build())),
			("Profile".localized, (UIImage.init(named: "profileTab"), ProfileViewController.init()))]
		
		self.viewControllers = tabs.map({ (tuple) -> UINavigationController in
			let nvc = UINavigationController(rootViewController: tuple.1.1)
			tuple.1.1.title = tuple.0
			nvc.tabBarItem = UITabBarItem(title: tuple.0, image: tuple.1.0, tag: 0)
			return nvc
		})
		
		self.miniPlayer.presentationDelegate = self
		self.view.insertSubview(miniPlayer, belowSubview: self.tabBar)
		miniPlayer.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			miniPlayerBottomConstr = make.bottom.equalTo(self.tabBar.snp.top).constraint.layoutConstraints.first
		}
		playerController.modalPresentationStyle = .overFullScreen
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		print(self.miniPlayer.frame)
	}
	
	func playerTapped() {
//		miniPlayerBottomConstr?.constant = miniPlayer.frame.height + self.tabBar.frame.height
//		UIView.animate(withDuration: 0.5) {
//			self.view.layoutIfNeeded()
//		}
		self.present(playerController, animated: true, completion: nil)
	}
	
	func popupPlayer(show: Bool, animated: Bool) {
//		if show {
//			if vc.popupPresentationState == .hidden && vc.popupPresentationContainer == nil {
//				self.presentPopupBar(withContentViewController: vc, animated: animated, completion: nil)
//			}
//		} else {
//			self.dismissPopupBar(animated: animated, completion: nil)
//		}
	}
	
	func showPlaylist() {
//		self.vc.openPopup(animated: true) {
//			print("Player Opened")
//		}
//		self.presentPopupBar(withContentViewController: vc, openPopup: true, animated: true, completion: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
			
		AppManager.shared.rootTabBarController = self
		AudioController.main.popupDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
//                AppManager.shared.audioPlayer?.showPlayer()
            }
            
//            if (root is ChannelsViewController || root is AboutViewController)
//                && !AppManager.shared.audioManager.isPlaying {
//                AppManager.shared.audioPlayer?.hidePlayer()
//            }
        }
    }
    
}
