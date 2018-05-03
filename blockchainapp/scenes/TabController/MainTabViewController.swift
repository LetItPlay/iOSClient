//
//  MainTabViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 04/09/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

enum HideMiniPlayerDirection {
    case left, right, down, up
}

class MainTabViewController: UITabBarController, AudioControllerPresenter, MiniPlayerPresentationDelegate {
	
	let router: MainRouter = MainRouter.shared
	
	let playerController = PlayerViewController()
	var miniPlayerBottomConstr: NSLayoutConstraint?
    var miniPlayerLeftConstr: NSLayoutConstraint?
    var miniPlayerRightConstr: NSLayoutConstraint?
	var playerIsShowed: Bool = false
    var playerWasShowed: Bool = false
	
	var currentNavigationViewController: UINavigationController? {
		get {
			return self.selectedViewController as? UINavigationController
		}
	}
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
		
		self.viewControllers = router.initialViewControllers
        self.router.currentNavigationController = self.viewControllers?.first as? UINavigationController
		self.router.delegate = self
		self.playerController.miniPlayer.presentationDelegate = self
		self.view.insertSubview(self.playerController.miniPlayer, belowSubview: self.tabBar)
		self.playerController.miniPlayer.snp.makeConstraints { (make) in
			miniPlayerLeftConstr = make.left.equalToSuperview().constraint.layoutConstraints.first
			miniPlayerRightConstr = make.right.equalToSuperview().constraint.layoutConstraints.first
			miniPlayerBottomConstr = make.bottom.equalTo(self.tabBar.snp.top).constraint.layoutConstraints.first
		}
		playerController.modalPresentationStyle = .overFullScreen
		
		miniPlayerBottomConstr?.constant = 120
        
        self.delegate = self
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 ) {
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
	
    func popupPlayer(show: Bool, animated: Bool, direction: HideMiniPlayerDirection) {
		
		self.view.layoutIfNeeded()
		
		if playerIsShowed && !show {
            switch direction {
            case .down:
                miniPlayerBottomConstr?.constant = self.playerController.miniPlayer.frame.height + self.tabBar.frame.height
            case .left:
                miniPlayerLeftConstr?.constant = self.tabBar.frame.width * (-1)
                miniPlayerRightConstr?.constant = self.tabBar.frame.width * (-1)
            case .right:
                miniPlayerLeftConstr?.constant = self.tabBar.frame.width
                miniPlayerRightConstr?.constant = self.playerController.miniPlayer.frame.width + self.tabBar.frame.width
            default: break
            }
            
			playerIsShowed = false
		}
        
		if !playerIsShowed && show {
			miniPlayerBottomConstr?.constant = 0
			playerIsShowed = true
		}
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            if !self.playerIsShowed {
                self.miniPlayerBottomConstr?.constant = self.playerController.miniPlayer.frame.height + self.tabBar.frame.height
                self.miniPlayerLeftConstr?.constant = 0
                self.miniPlayerRightConstr?.constant = 0
            }
        }
	}
	
	func showPlaylist() {
        if !self.playerIsPresenting && !self.playerWasShowed {
            self.playerController.showPlaylist()
            if !self.playerController.isBeingPresented {
                UIApplication.shared.beginIgnoringInteractionEvents()
                self.playerIsPresenting = true
                self.present(self.playerController, animated: true) {
                    self.playerIsPresenting = false
                    self.playerWasShowed = true
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
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

extension MainTabViewController: UITabBarControllerDelegate {
    
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
		if let title = self.viewControllers?[self.selectedIndex].tabBarItem.title {
			self.tabSelected(controller: title)
		}
        tabBarController.tabBar.items?[tabBarController.selectedIndex].badgeValue = nil
        if let nc = viewController as? UINavigationController {
			self.router.currentNavigationController = nc
        }
    }
	
    func tabSelected(controller: String)
    {
        AnalyticsEngine.sendEvent(event: .tabSelected(controller: controller))
    }
}

extension MainTabViewController: MainRouterDelegate {
    func showAllChannels() {
        self.selectedIndex = 3
    }
}
