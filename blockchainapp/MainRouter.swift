//
//  MainRouter.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 22/02/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import RxSwift

protocol Router {
	func show(screen id: String, params: [String: Any], present: Bool)
}

class MainRouter: Router {
	static let shared: MainRouter = MainRouter()
	
	private (set) internal var mainController: MainTabViewController!
	let playerHandler: PlayerHandler = PlayerHandler()
	weak var currentNavigationController: UINavigationController?
	
	let disposeBag: DisposeBag = DisposeBag()
    
    var delegate: MainRouterDelegate?
	
	init() {
		self.mainController = MainTabViewController(vcs: tabs(), miniPlayer: playerHandler.miniPlayer)
		self.mainController.router = self
	}
	
	func tabs() -> [UINavigationController] {
		let tabs: [(String, (UIImage?, UIViewController?))] = [
			("Feed".localized, (UIImage.init(named: "feedTab"), FeedBuilder.build(params: nil))),
			("Trends".localized, (UIImage.init(named: "trendsTab"), PopularBuilder.build(params: nil))),
			("Playlists".localized, (UIImage.init(named: "playlistsTab"), PlaylistsTab())),
			("Channels".localized, (UIImage(named: "channelsTab"), ChannelsSegmentViewController(nibName: nil, bundle: nil))), //CategoryChannelsBuilder.build(params: nil))),
			("Profile".localized, (UIImage.init(named: "profileTab"), ProfileBuilder.build(params: nil)))]
		
		return tabs.map({ (tuple) -> UINavigationController in
			let nvc = UINavigationController(rootViewController: tuple.1.1!)
			tuple.1.1!.title = tuple.0
			nvc.tabBarItem = UITabBarItem(title: tuple.0, image: tuple.1.0, tag: 0)
			return nvc
		})
	}
	
	func miniPlayer(show: Bool, animated: Bool) {
		self.mainController.popupPlayer(show: show, animated: animated, direction: .up)
	}
	
	func mainPlayer(show: Bool, index: Int = 0) {
		if !self.playerHandler.main.isBeingPresented{
			UIApplication.shared.beginIgnoringInteractionEvents()
//			self.playerIsPresenting = true
			self.mainController.present(self.playerHandler.main, animated: true) {
//				self.playerIsPresenting = false
				UIApplication.shared.endIgnoringInteractionEvents()
			}
		}
		self.playerHandler.main.setScreen(index: index)
	}
	
	func show(screen id: String, params: [String : Any], present: Bool) {
		var vc: UIViewController?
		switch id {
		case "channel":
			vc = ChannelBuilder.build(params: params)
			break
		case "allChannels":
            self.delegate?.showAllChannels()
			return
        case "search":
            vc = SearchBuilder.build(params: params)
            (vc as! SearchViewController).delegate = self
			self.currentNavigationController?.viewControllers.first?.navigationItem.rightBarButtonItem?.isEnabled = false
		default:
			print("did nothing right/wrong")
		}
		
		if let vc = vc {
			if present {
				let close = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
				vc.navigationItem.leftBarButtonItem = close
				close.rx.tap.subscribe(onNext: { _ in
					vc.dismiss(animated: true, completion: nil)
				}).disposed(by: disposeBag)
			} else {
                self.currentNavigationController?.pushViewController(vc, animated: true)
			}
		}
	}
    
    func hidePlayer() {
        self.delegate?.hidePlayer()
    }
    
    func showOthers(track: Any) {
        let controller: UIViewController!
//        if let currentController = viewController {
//            controller = currentController
//        } else {
            controller = self.currentNavigationController?.viewControllers.first
//        }
		
        let othersController = OthersBuilder.build(params: ["controller" : controller, "track": track]) as! OthersAlertController
        controller?.present(othersController, animated: true, completion: nil)
    }
    
    func share(data: ShareInfo, viewController: UIViewController?) {
        let controller: UIViewController!
        if let currentController = viewController {
            controller = currentController
        } else {
            controller = self.currentNavigationController?.viewControllers.first
        }
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [data.text, data.url, data.image], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
         DispatchQueue.global(qos: .background).async {
            controller.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension MainRouter: SearchViewControllerDelegate {
    func searchDidDisappear() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.currentNavigationController?.viewControllers.first?.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}

protocol MainRouterDelegate {
    func showAllChannels()
    func hidePlayer()
}
