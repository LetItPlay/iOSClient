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
	var miniPlayerBottomConstr: NSLayoutConstraint?
	var playerIsShowed: Bool = false
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
		
		let tabs: [(String, (UIImage?, UIViewController))] = [
			("Feed".localized, (UIImage.init(named: "feedTab"), FeedBuilder.build(params: nil))),
			("Trends".localized, (UIImage.init(named: "trendsTab"), PopularBuilder.build(params: nil))),
			("Search".localized, (UIImage.init(named: "searchTab"), SearchViewController())),
			("Profile".localized, (UIImage.init(named: "profileTab"), ProfileBuilder.build()))]
		
		self.viewControllers = tabs.map({ (tuple) -> UINavigationController in
			let nvc = UINavigationController(rootViewController: tuple.1.1)
			tuple.1.1.title = tuple.0
			nvc.tabBarItem = UITabBarItem(title: tuple.0, image: tuple.1.0, tag: 0)
			return nvc
		})
		
		self.playerController.miniPlayer.presentationDelegate = self
		self.view.insertSubview(self.playerController.miniPlayer, belowSubview: self.tabBar)
		self.playerController.miniPlayer.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			miniPlayerBottomConstr = make.bottom.equalTo(self.tabBar.snp.top).constraint.layoutConstraints.first
		}
		playerController.modalPresentationStyle = .overFullScreen
		
		miniPlayerBottomConstr?.constant = 120
		
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	var playerIsPresenting: Bool = false
	
	func playerTapped() {
//		miniPlayerBottomConstr?.constant = miniPlayer.frame.height + self.tabBar.frame.height
//		UIView.animate(withDuration: 0.5) {
//			self.view.layoutIfNeeded()
//		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
			if !self.playerController.isBeingPresented {
				UIApplication.shared.beginIgnoringInteractionEvents()
				self.playerIsPresenting = true
				self.present(self.playerController, animated: true) {
					self.playerIsPresenting = false
					UIApplication.shared.endIgnoringInteractionEvents()
				}
			}
		}
	}
	
	func popupPlayer(show: Bool, animated: Bool) {
		
		self.view.layoutIfNeeded()
		
		if playerIsShowed && !show {
			miniPlayerBottomConstr?.constant = self.playerController.miniPlayer.frame.height + self.tabBar.frame.height
			playerIsShowed = false
		}
		if !playerIsShowed && show {
			miniPlayerBottomConstr?.constant = 0
			playerIsShowed = true 
		}
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	func showPlaylist() {
		self.playerController.showPlaylist()
		if !self.playerController.isBeingPresented {
			UIApplication.shared.beginIgnoringInteractionEvents()
			self.playerIsPresenting = true
			self.present(self.playerController, animated: true) {
				self.playerIsPresenting = false
				UIApplication.shared.endIgnoringInteractionEvents()
			}
		}
	}
	
	func hidePlayer() {
		self.playerController.dismiss(animated: true) {
			print("player dismissed")
		}
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
        self.tabSelected(controller: controllersNames[tabBarController.selectedIndex])
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
    
    let controllersNames = ["Feed", "Trends", "Search", "Profile"]
    
    func tabSelected(controller: String)
    {
        AnalyticsEngine.sendEvent(event: .tabSelected(controller: controller))
    }
}
