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

class PlayerViewController: UIViewController, AudioControllerDelegate {
	
	let miniPlayer: MiniPlayerView = MiniPlayerView()
	let audioController = AudioController.main
	
	let pageController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: [:])
	let mainPlayer: MainPlayerViewController = MainPlayerViewController()
	let playlist: PlaylistViewController = PlaylistViewController()
    var trackInfo: TrackInfoViewController!
    
    var bottomIconsView: MainPlayerBottomIconsView!
	
	var mask: CAShapeLayer!
	let ind = ArrowView()
    
    var currentTrackID: Int = -1
    
    var isMainPlayer: Bool = true
    
	init() {
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
		pageController.setViewControllers([mainPlayer], direction: .forward, animated: false, completion: nil)
        
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
		
		audioController.delegate = self
		
		self.ind.setFlat(false)
        
        bottomIconsView = MainPlayerBottomIconsView(frame: self.view.frame)
        bottomIconsView.emitter = MainPlayerBottomIconsEmitter(model: self)
        
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
	
	func updateTime(time: (current: Double, length: Double)) {
		DispatchQueue.main.async {
			if time.current >= 0 && time.length >= 0 {
				self.miniPlayer.progressView.progress = Float(time.current / time.length)
				if !self.mainPlayer.trackProgressView.slider.isHighlighted {
					self.mainPlayer.trackProgressView.slider.value = Float(time.current / time.length)
				}
				self.mainPlayer.trackProgressView.trackProgressLabels.start.text = Int64(time.current).formatTime()
				self.mainPlayer.trackProgressView.trackProgressLabels.fin.text = "-" + Int64(abs(time.length - time.current)).formatTime()
			}
		}
	}
	
	func playState(isPlaying: Bool) {
		self.miniPlayer.playButton.isSelected = isPlaying
		self.mainPlayer.playButton.isSelected = isPlaying
		if isPlaying {
			self.playlist.currentIndex = self.audioController.currentTrackIndexPath
		} else {
			self.playlist.currentIndex = IndexPath.invalid
		}
		self.playlist.tableView.reloadData()
	}
	
	func trackUpdate() {
		DispatchQueue.main.async {
			if let ob = self.audioController.currentTrack {
                
                if self.currentTrackID == -1 {
                    self.currentTrackID = ob.id
                    self.trackInfo = TrackInfoBuilder.build(params: ["id" : self.currentTrackID]) as! TrackInfoViewController
                    self.trackInfo.trackInfoHeaderView.delegate = self
                }
                
                if self.currentTrackID != ob.id {
                    self.currentTrackID = ob.id
                    self.trackInfo.trackInfoHeaderView.emitter?.send(event: TrackInfoEvent.updateTrack(id: self.currentTrackID))
                }
                
				let channel = ob.author
				let title = ob.name

				self.miniPlayer.trackAuthorLabel.text = channel
				self.miniPlayer.trackNameLabel.text = title
				self.mainPlayer.channelNameLabel.text = channel
				self.mainPlayer.trackNameLabel.text = title
				if let url = ob.imageURL {
                    self.mainPlayer.underblurimageView.image = UIImage(named: "trackPlaceholder")
					self.mainPlayer.coverImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "trackPlaceholder"), options: SDWebImageOptions.refreshCached, completed: { (img, error, type, url) in
						self.miniPlayer.trackImageView.image = img
						self.mainPlayer.setPicture(image: img)
					})
				}
			}
			if self.audioController.status != .playing {
				let info = self.audioController.info
				if info.current >= 0 && info.current >= 0 {
					UIView.animate(withDuration: 0.01, animations: {
						self.mainPlayer.trackProgressView.slider.value = Float(info.current/info.length)
						self.mainPlayer.trackProgressView.trackProgressLabels.start.text = Int64(info.current).formatTime()
						self.mainPlayer.trackProgressView.trackProgressLabels.fin.text = "-" + Int64(abs(info.length - info.current)).formatTime()

						self.miniPlayer.progressView.progress = Float(info.current/info.length)
					})
				}
			}
//			self.playlist.currentIndex = self.audioController.currentTrackIndexPath
//			self.playlist.tableView.reloadData()
//			self.playlist.isHidden = false
		}
//		self.playButton.isSelected = audioController.status == .playing
//		self.playerView.playButton.isSelected = audioController.status == .playing
	}
	
	func playlistChanged() {
		self.miniPlayer.trackNameLabel.text = ""
		self.miniPlayer.trackAuthorLabel.text = ""
		self.miniPlayer.progressView.progress = 0.0
		self.mainPlayer.channelNameLabel.text = ""
		self.mainPlayer.trackNameLabel.text = ""
		self.mainPlayer.coverImageView.image = UIImage(named: "trackPlaceholder")
        self.mainPlayer.underblurimageView.image = UIImage(named: "trackPlaceholder")

		self.playlist.tracks = [self.audioController.userPlaylist.tracks, self.audioController.playlist.tracks]
		self.playlist.currentIndex = self.audioController.currentTrackIndexPath
		self.playlist.tableView.reloadData()
	}
	
	func showPlaylist() {
		self.pageController.setViewControllers([playlist], direction: .forward, animated: false, completion: nil)
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
 
    func change(speed: Float) {
        self.audioController.player.set(rate: speed)
    }
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}

extension PlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.pageController.viewControllers![0] is MainPlayerViewController && self.isMainPlayer {
            if scrollView.contentOffset.x > self.view.frame.width {
                let width = self.view.frame.width
                self.bottomIconsView.hideIcons((scrollView.contentOffset.x / width - 2) * -1 )
                print(scrollView.contentOffset.x)
            }
        }
        if self.pageController.viewControllers![0] is PlaylistViewController {
            if scrollView.contentOffset.x < self.view.frame.width {
                let width = self.view.frame.width
                self.bottomIconsView.hideIcons((scrollView.contentOffset.x / width - 1) * -1 )
            }
        }
    }
}

extension PlayerViewController: TrackLikedDelegate
{
    func track(liked: Bool) {
        bottomIconsView.trackLikeButton.setImage(UIImage(named: liked ? "likeActiveFeed" : "likeInactiveFeed"), for: .normal)
    }
}

extension PlayerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        self.bottomIconsView.hideIcons(false)
        
        self.isMainPlayer = false

		if viewController is PlaylistViewController {
			return mainPlayer
		}
        
        if viewController is MainPlayerViewController {
            self.isMainPlayer = true
            return trackInfo
        }
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if viewController is MainPlayerViewController {
            self.isMainPlayer = true
			return playlist
		}
        
        self.isMainPlayer = false

        if viewController is TrackInfoViewController {
            return mainPlayer
        }

        self.bottomIconsView.hideIcons(true)
		
		return nil
	}
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if pageViewController.viewControllers![0] is PlaylistViewController {
            return 2
        }

        if pageController.viewControllers![0] is TrackInfoViewController {
            return 0
        }
        return 1
    }
}

extension PlayerViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PlayerPresentTransition.init(originFrame: self.view.frame)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PlayerDismissTransition.init(originFrame: self.view.frame)
	}
}

extension PlayerViewController: MainPlayerBottomIconsEventHandler {
    func likeButtonTouched() {
        if let _ = self.trackInfo.trackInfoHeaderView.viewModel.track {
        self.bottomIconsView.trackLikeButton.setImage(UIImage(named: self.trackInfo.trackInfoHeaderView.viewModel.track.isLiked ? "likeInactiveFeed" : "likeActiveFeed"), for: .normal)
            let id = AudioController.main.currentTrack?.id
            self.trackInfo.trackInfoHeaderView.emitter?.send(event: TrackInfoEvent.trackLiked(index: id!))
        }
    }
    
    func speedButtonTouched(speedAlert: UIAlertController) {
        self.present(speedAlert, animated: true, completion: nil)
    }
    
    func showOthersButtonTouched() {
        MainRouter.shared.showOthers(track: AudioController.main.currentTrack as Any, viewController: self)
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
