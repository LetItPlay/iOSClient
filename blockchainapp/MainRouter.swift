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
	
	weak var currentNavigationController: UINavigationController?
	let initialViewControllers: [UIViewController]
	
	let disposeBag: DisposeBag = DisposeBag()
    
    var delegate: MainRouterDelegate?
	
	init() {
		
		let tabs: [(String, (UIImage?, UIViewController?))] = [
			("Feed".localized, (UIImage.init(named: "feedTab"), FeedBuilder.build(params: nil))),
			("Trends".localized, (UIImage.init(named: "trendsTab"), PopularBuilder.build(params: nil))),
            ("Playlists".localized, (UIImage.init(named: "playlistsTab"), PlaylistsTab())),
            ("Channels".localized, (UIImage(named: "channelsTab"), ChannelsBuilder.build(params: nil))),
			("Profile".localized, (UIImage.init(named: "profileTab"), ProfileBuilder.build(params: nil)))]
		
		self.initialViewControllers = tabs.map({ (tuple) -> UINavigationController in
			let nvc = UINavigationController(rootViewController: tuple.1.1!)
			tuple.1.1!.title = tuple.0
			nvc.tabBarItem = UITabBarItem(title: tuple.0, image: tuple.1.0, tag: 0)
			return nvc
		})
		
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
        let controller = self.currentNavigationController?.viewControllers.first
        let othersController = OthersViewController()
        othersController.add(track: track)
        othersController.add(controller: (controller)!)
        controller?.present(othersController, animated: true, completion: nil)
    }
    
    func shareTrack(track: Any, viewController: UIViewController) {
        
        var sharedText: String!
        var sharedImage: UIImage!
        var sharedUrl: String!
        
        if let track = track as? Track {
            sharedText = "\"\(track.name)\" - \(track.channel.name)"
            sharedImage = try! UIImage(data: Data(contentsOf: (track.image)!))!
            sharedUrl = RequestManager.server + "/tracks/\(track.id)"
        }
        if let track = track as?  AudioTrack {
            sharedText = "\"\(track.name)\" - \(track.author)"
            sharedImage = try! UIImage(data: Data(contentsOf: (track.imageURL)!))!
            sharedUrl = RequestManager.server + "/tracks/\(track.id)"
        }
        
        if let track = track as? TrackObject {
            sharedText = "\"\(track.name)\" - \(track.channel)"
            sharedImage = try! UIImage(data: Data.init(contentsOf: track.image.url()!))
            sharedUrl = RequestManager.server + "/tracks/\(track.id)"
        }
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [sharedText, sharedUrl, sharedImage], applicationActivities: nil)
        
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
        
        viewController.present(activityViewController, animated: true, completion: nil)
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
