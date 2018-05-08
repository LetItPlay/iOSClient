//
//  PlayerViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

protocol TrackLikedDelegate {
    func track(liked: Bool)
}

class MainPlayerViewController: UIViewController {
	
	let pageController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: [:])
    var trackInfo: TrackInfoViewController!
    
    var bottomIconsView: MainPlayerBottomIconsView!
	
	var mask: CAShapeLayer!
	let arrowView = ArrowView()
    
    var currentTrackID: Int = -1
    var defaultIndex: Int = 0
	
	var isMainPlayer: Bool = true
    
    var vcs: [UIViewController]
	
    init(vcs: [UIViewController], defaultIndex: Int? = nil, bottom: MainPlayerBottomIconsView? = nil) {
        self.vcs = vcs
        super.init(nibName: nil, bundle: nil)

		pageController.delegate = self

        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = AppColor.Title.lightGray
        appearance.currentPageIndicatorTintColor = .red
				
		self.view.addSubview(pageController.view)
		pageController.view.snp.makeConstraints { (make) in
			make.top.equalTo(UIApplication.shared.statusBarFrame.height)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		pageController.view.backgroundColor = .white
		pageController.delegate = self
		pageController.dataSource = self
        
        if let def = defaultIndex {
            self.defaultIndex = def
        }
        pageController.setViewControllers([self.vcs[self.defaultIndex]], direction: .forward, animated: false, completion: nil)
		
        for scroll in pageController.view.subviews{
            if scroll.isKind(of: UIScrollView.self){
                scroll.setContentHuggingPriority(.init(100), for: .horizontal)
                (scroll as! UIScrollView).delegate = self
            }
        }
		
		self.mask = CAShapeLayer.init()
		self.view.layer.mask = self.mask
		
		let panGest = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
		self.view.addGestureRecognizer(panGest)
		
//		self.transitioningDelegate = self
		
		self.view.addSubview(arrowView)
		arrowView.snp.makeConstraints { (make) in
			make.width.equalTo(37)
			make.height.equalTo(12)
			make.top.equalTo(pageController.view.snp.top).inset(40)
			make.centerX.equalToSuperview()
		}
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
		arrowView.addGestureRecognizer(tap)
		
		self.arrowView.setFlat(false)
        
        if let bottom = bottom {
            bottomIconsView = bottom
        } else {
            bottomIconsView = MainPlayerBottomIconsView(frame: self.view.frame)
            bottomIconsView.emitter = MainPlayerBottomIconsEmitter(model: self)
        }
		
        self.view.addSubview(bottomIconsView)
        bottomIconsView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
	}
	
	@objc func arrowTapped() {
		self.dismiss(animated: true) {
			print("Player dismissed")
		}
	}
	
	func setScreen(index: Int) {
		self.pageController.setViewControllers([self.vcs[index]], direction: .forward, animated: false) { (finished) in
			
		}
	}
	
	@objc func pan(gesture: UIPanGestureRecognizer) {
		let threshhold = self.view.frame.size.height / 4
		switch gesture.state {
		case .changed:
			let acc: CGFloat = 0.618
			let point = gesture.translation(in: self.view)
			if point.y < 0 {
				self.view.frame.origin.y = 0.0
			} else if point.y < threshhold + 20 {
				self.view.frame.origin.y = point.y - acc*point.y
			}
            let velo = gesture.velocity(in: self.view)
            if velo.y > 0 {
                self.arrowView.setFlat(true, animated: true)
            }
			break
		case .ended:
			let point = gesture.translation(in: self.view)
			if point.y >= threshhold/2 {
				self.dismiss(animated: true, completion: {
					self.view.frame.origin.y = 0.0
					print("Player dismissed")
                    self.arrowView.setFlat(false, animated: true)
				})
			} else {
				UIApplication.shared.beginIgnoringInteractionEvents()
				UIView.animate(withDuration: 0.2, animations: {
					self.view.frame.origin.y = 0.0
				}, completion: { (completed) in
					UIApplication.shared.endIgnoringInteractionEvents()
                    self.arrowView.setFlat(false, animated: true)
				})
			}
		default:

			break
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.mask.path = CGPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: 0, y: 20), size: self.view.frame.size), cornerWidth: 10, cornerHeight: 10, transform: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}

extension MainPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.pageController.viewControllers![0] is MainPlayerViewController && self.isMainPlayer {
            if scrollView.contentOffset.x > self.view.frame.width {
                let width = self.view.frame.width
                self.bottomIconsView.hideIcons((scrollView.contentOffset.x / width - 2) * -1 )
                print(scrollView.contentOffset.x)
            }
        }
        if self.pageController.viewControllers![0] is PlayingPlaylistViewController {
            if scrollView.contentOffset.x < self.view.frame.width {
                let width = self.view.frame.width
                self.bottomIconsView.hideIcons((scrollView.contentOffset.x / width - 1) * -1 )
            }
        }
    }
}

extension MainPlayerViewController: TrackLikedDelegate{
    func track(liked: Bool) {
        bottomIconsView.trackLikeButton.setImage(UIImage(named: liked ? "likeActiveFeed" : "likeInactiveFeed"), for: .normal)
    }
}

extension MainPlayerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.vcs.index(where: {$0 == viewController}), index > 0 {
            return self.vcs[index - 1]
		}
//
//        self.bottomIconsView.hideIcons(false)
//
//        self.isMainPlayer = false
//
//		if viewController is PlaylistViewController {
//			return mainPlayer
//		}
//
//        if viewController is MainPlayerViewController {
//            self.isMainPlayer = true
//            return trackInfo
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.vcs.index(where: {$0 == viewController}), index < self.vcs.count - 1 {
            return self.vcs[index + 1]
        }
//		if viewController is MainPlayerViewController {
//            self.isMainPlayer = true
//			return playlist
//		}
//
//        self.isMainPlayer = false
//
//        if viewController is TrackInfoViewController {
//            return mainPlayer
//        }
//
//        self.bottomIconsView.hideIcons(true)
		
		return nil
	}
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.vcs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let vc = pageViewController.viewControllers?[0], let index = self.vcs.index(where: {$0 == vc}) {
            return index
		}
//        if pageViewController.viewControllers![0] is PlaylistViewController {
//            return 2
//        }
//
//        if pageController.viewControllers![0] is TrackInfoViewController {
//            return 0
		return 0
	}
}

//extension MainPlayerViewController: UIViewControllerTransitioningDelegate {
//	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//		return PlayerPresentTransition.init(originFrame: self.view.frame)
//	}
//
//	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//		return PlayerDismissTransition.init(originFrame: self.view.frame)
//	}
//}

extension MainPlayerViewController: MainPlayerBottomIconsEventHandler {
    
    func likeButtonTouched() {
        if let _ = self.trackInfo.trackInfoHeaderView.viewModel.track {
        self.bottomIconsView.trackLikeButton.setImage(UIImage(named: self.trackInfo.trackInfoHeaderView.viewModel.track.isLiked ? "likeInactiveFeed" : "likeActiveFeed"), for: .normal)
            let id = AudioController.main.currentTrack?.id
            self.trackInfo.trackInfoHeaderView.emitter?.send(event: TrackInfoEvent.trackLiked(index: id!))
        }
    }
    
    func speedButtonTouched() {
    }
    
    func showOthersButtonTouched() {
    }
}

class PlayerTransition: NSObject, UIViewControllerAnimatedTransitioning {
	
	private let originFrame: CGRect
	
	init(originFrame: CGRect) {
		self.originFrame = originFrame
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.5
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
	}
}

class PlayerPresentTransition: PlayerTransition {
	override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(0)
		
		guard let to = transitionContext.viewController(forKey: .to),
		let _ = transitionContext.viewController(forKey: .from) else { return }
		
		let containerView = transitionContext.containerView
		let finalFrame = transitionContext.finalFrame(for: to)
		
		containerView.addSubview(to.view)
		to.view.isHidden = false
		
		let duration = transitionDuration(using: transitionContext)
		
		to.view.frame.size = finalFrame.size
		to.view.frame.origin = CGPoint.init(x: 0, y: finalFrame.size.height)
		
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 10, initialSpringVelocity: 10.0, options: .curveEaseInOut, animations: {
			to.view.frame.origin = CGPoint.zero
			containerView.layer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
		}) { (completed) in
			print("Animation completed: \(completed)")
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}
}

class PlayerDismissTransition: PlayerTransition {
	override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(0)
		
		guard let from = transitionContext.viewController(forKey: .from) as? PlayerViewController else { return }
		
		
		let containerView = transitionContext.containerView
		containerView.layer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
		let duration = transitionDuration(using: transitionContext)
		
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 10, initialSpringVelocity: 10.0, options: .curveEaseInOut, animations: {
			from.view.frame.origin = CGPoint(x: 0, y: from.view.frame.height)
			containerView.layer.backgroundColor = UIColor.clear.cgColor
		}) { (completed) in
			print("Animation completed: \(completed)")
			from.view.removeFromSuperview()
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}
}
