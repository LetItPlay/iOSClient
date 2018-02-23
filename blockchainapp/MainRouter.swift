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
	weak var currentNavigationController: UINavigationController?
	let initialViewControllers: [UIViewController]
	
	let disposeBag: DisposeBag = DisposeBag()
	
	init() {
		
		let tabs: [(String, (UIImage?, UIViewController))] = [
			("Feed".localized, (UIImage.init(named: "feedTab"), FeedBuilder.build(params: nil))),
			("Trends".localized, (UIImage.init(named: "trendsTab"), PopularBuilder.build(params: nil))),
			("Search".localized, (UIImage.init(named: "searchTab"), SearchBuilder.build(params: nil))),
			("Profile".localized, (UIImage.init(named: "profileTab"), ProfileBuilder.build(params: nil)))]
		
		self.initialViewControllers = tabs.map({ (tuple) -> UINavigationController in
			let nvc = UINavigationController(rootViewController: tuple.1.1)
			tuple.1.1.title = tuple.0
			nvc.tabBarItem = UITabBarItem(title: tuple.0, image: tuple.1.0, tag: 0)
			return nvc
		})
		
	}
	
	func show(screen id: String, params: [String : Any], present: Bool) {
		var vc: UIViewController?
		switch id {
		case "channel":
			
			break
		case "allChannels":
			vc = ChannelsBuilder.build(params: params)
			break
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
}
