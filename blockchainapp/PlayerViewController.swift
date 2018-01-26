//
//  PlayerViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class PlayerViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	let miniPlayer: MiniPlayerView = MiniPlayerView()
	
	let pageController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: [:])
	let mainPlayer: MainPlayerViewController = MainPlayerViewController()
	let playlist: PlaylistViewController = PlaylistViewController()
	
	var mask: CAShapeLayer!
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		pageController.delegate = self
		
		self.view.addSubview(pageController.view)
		pageController.view.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(64)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		pageController.view.backgroundColor = .white
		self.view.backgroundColor = .red
		
		self.mask = CAShapeLayer.init()
		self.view.layer.mask = self.mask
		
		let panGest = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
		self.view.addGestureRecognizer(panGest)
	}
	
	@objc func pan(gesture: UIPanGestureRecognizer) {
		let threshhold = self.view.frame.size.height / 2
		switch gesture.state {
		case .changed:
			let acc: CGFloat = 0.618
			let point = gesture.translation(in: self.view)
			print(point)
			if point.y < 0 {
				self.view.frame.origin.y = 0.0
			} else if point.y < threshhold + 20 {
				self.view.frame.origin.y = point.y - acc*point.y
			}
			break
		case .ended:
			let point = gesture.translation(in: self.view)
			if point.y >= threshhold/3 {
				self.dismiss(animated: true, completion: {
					self.view.frame.origin.y = 0.0
					print("Player dismissed")
				})
			} else {
				UIApplication.shared.beginIgnoringInteractionEvents()
				UIView.animate(withDuration: 0.2, animations: {
					self.view.frame.origin.y = 0.0
				}, completion: { (completed) in
					UIApplication.shared.endIgnoringInteractionEvents()
				})
			}
		default:

			break
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.mask.path = CGPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: 0, y: 20), size: self.view.frame.size), cornerWidth: 40, cornerHeight: 40, transform: nil)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if viewController is PlaylistViewController {
			return mainPlayer
		}
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if viewController is MainPlayerViewController {
			return playlist
		}
		
		return nil
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}
