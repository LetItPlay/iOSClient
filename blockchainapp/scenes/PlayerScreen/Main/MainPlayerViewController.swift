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

    var vcs: [UIViewController]!

    var trackLikeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "likeInactiveFeed"), for: .normal)
        return button
    }()
    
    var trackSpeedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "timespeedInactive"), for: .normal)
//        button.addTarget(self, action: #selector(trackSpeedButtonTouched), for: .touchUpInside)
        return button
    }()
    
    var sharedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "sharedInactive"), for: .normal)
//        button.addTarget(self, action: #selector(sharedButtonTouched), for: .touchUpInside)
        return button
    }()
    
    var speeds: [(text: String, value: Float)] = [(text: "x 0.25", value: 0.25), (text: "x 0.5", value: 0.5), (text: "x 0.75", value: 0.75), (text: "Default".localized, value: 1), (text: "x 1.25", value: 1.25), (text: "x 1.5", value: 1.5), (text: "x 2", value: 2)]
	
	var mask: CAShapeLayer!
	let ind = ArrowView()
    
    var currentTrackID: Int = -1
    
	init(vcs: [UIViewController]) {
//        self.mainPlayer = self.playerBuilder.playerVC
        self.vcs = vcs
        super.init(nibName: nil, bundle: nil)

		pageController.delegate = self

        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = AppColor.Title.lightGray
        appearance.currentPageIndicatorTintColor = .red
				
		self.view.addSubview(pageController.view)
		pageController.view.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		pageController.view.backgroundColor = .white
		pageController.delegate = self
		pageController.dataSource = self
		if let vc = self.vcs.first {
			pageController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
		}
		
        for scroll in pageController.view.subviews{
            if scroll.isKind(of: UIScrollView.self){
                scroll.setContentHuggingPriority(.init(100), for: .horizontal)
            }
        }
		
		self.mask = CAShapeLayer.init()
		self.view.layer.mask = self.mask
		
		let panGest = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
		self.view.addGestureRecognizer(panGest)
		
		self.transitioningDelegate = self
		
		self.view.addSubview(ind)
		ind.snp.makeConstraints { (make) in
			make.width.equalTo(37)
			make.height.equalTo(12)
			make.top.equalToSuperview().inset(40)
			make.centerX.equalToSuperview()
		}
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
		ind.addGestureRecognizer(tap)
		
		self.ind.setFlat(false)
        
        self.view.addSubview(trackLikeButton)
        trackLikeButton.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view.frame.width / 10 - 12)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        })
        
        self.view.addSubview(trackSpeedButton)
        trackSpeedButton.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view.frame.width / 4)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        })
        
        self.view.addSubview(sharedButton)
        sharedButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(self.view.frame.width / 10 - 12)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
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
                self.ind.setFlat(true, animated: true)
            }
			break
		case .ended:
			let point = gesture.translation(in: self.view)
			if point.y >= threshhold/2 {
				self.dismiss(animated: true, completion: {
					self.view.frame.origin.y = 0.0
					print("Player dismissed")
                    self.ind.setFlat(false, animated: true)
				})
			} else {
				UIApplication.shared.beginIgnoringInteractionEvents()
				UIView.animate(withDuration: 0.2, animations: {
					self.view.frame.origin.y = 0.0
				}, completion: { (completed) in
					UIApplication.shared.endIgnoringInteractionEvents()
                    self.ind.setFlat(false, animated: true)
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
    
//    @objc func trackLikeButtonTouched()
//    {
//        if let _ = self.trackInfo.trackInfoHeaderView.viewModel.track {
//            self.trackLikeButton.setImage(UIImage(named: self.trackInfo.trackInfoHeaderView.viewModel.track.isLiked ? "likeInactiveFeed" : "likeActiveFeed"), for: .normal)
//            let id = self.audioController.currentTrack?.id
//            self.trackInfo.trackInfoHeaderView.emitter?.send(event: TrackInfoEvent.trackLiked(index: id!))
//        }
//    }
//
//    @objc func trackSpeedButtonTouched()
//    {
//        let currentSpeed = self.audioController.player.chosenRate == -1 ? 1 : self.audioController.player.chosenRate
//
//        let speedAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
//
//        speedAlert.view.tintColor = AppColor.Title.lightGray
//
//        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
//        let messageAttrString = NSMutableAttributedString(string: "The playback speed of audio".localized, attributes: messageFont)
//        speedAlert.setValue(messageAttrString, forKey: "attributedTitle")
//
//        for speed in speeds {
//            if speed.value == currentSpeed {
//                speedAlert.addAction(UIAlertAction(title: speed.text, style: .default, handler: { _ in
//                    self.change(speed: speed.value)
//                }))
//            }
//            else {
//                speedAlert.addAction(UIAlertAction(title: speed.text, style: .destructive, handler: { _ in
//                    self.change(speed: speed.value)
//                }))
//            }
//        }
//
//        speedAlert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .destructive, handler: nil))
//
//        self.present(speedAlert, animated: true, completion: nil)
//    }
//
//    @objc func sharedButtonTouched() {
//        MainRouter.shared.shareTrack(track: self.audioController.currentTrack, viewController: self)
//    }
//
//    func change(speed: Float) {
//        self.audioController.player.set(rate: speed)
//    }
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}

extension MainPlayerViewController: TrackLikedDelegate
{
    func track(liked: Bool) {
        trackLikeButton.setImage(UIImage(named: liked ? "likeActiveFeed" : "likeInactiveFeed"), for: .normal)
    }
}

extension MainPlayerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.vcs.index(where: {$0 == viewController}), index > 0 {
            return self.vcs[index - 1]
        }
//		if viewController is PlayingPlaylistViewController {
//			return mainPlayer
//		}
//
//        if viewController is MainPlayerViewController {
//            return trackInfo
//        }
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.vcs.index(where: {$0 == viewController}), index < self.vcs.count - 2 {
            return self.vcs[index + 1]
        }
//		if viewController is MainPlayerViewController {
//			return playlist
//		}
//
//        if viewController is TrackInfoViewController {
//            return mainPlayer
//        }
		
		return nil
	}
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.vcs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let vc = pageViewController.viewControllers?[0], let index = self.vcs.index(where: {$0 == vc}) {
            return index
        }

        return 0
//        if pageViewController.viewControllers![0] is PlaylistViewController {
//            return 2
//        }
//        if pageController.viewControllers![0] is TrackInfoViewController {
//            return 0
//        }
//        return 1
    }
}

extension MainPlayerViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PlayerPresentTransition.init(originFrame: self.view.frame)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PlayerDismissTransition.init(originFrame: self.view.frame)
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