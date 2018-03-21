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

class PlayerViewController: UIViewController, AudioControllerDelegate {
	
	let miniPlayer: MiniPlayerView = MiniPlayerView()
	let audioController = AudioController.main
	
	let pageController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: [:])
	let mainPlayer: MainPlayerViewController = MainPlayerViewController()
	let playlist: PlaylistViewController = PlaylistViewController()
    var trackInfo: TrackInfoViewController!
    
    var trackLikeButton: UIButton = UIButton()
    var trackSpeedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "timespeedInactive"), for: .normal)
        button.addTarget(self, action: #selector(trackSpeedButtonTouched), for: .touchUpInside)
        return button
    }()
    
    var speeds = [(text: "x 0.25", value: 0.25), (text: "x 0.5", value: 0.5), (text: "x 0.75", value: 0.75), (text: "Default".localized, value: 1), (text: "x 1.25", value: 1.25), (text: "x 1.5", value: 1.5), (text: "x 2", value: 2)]
	
	var mask: CAShapeLayer!
	let ind = ArrowView()
    
    var currentTrackID: Int = -1
    
	init() {
		super.init(nibName: nil, bundle: nil)
		
		pageController.delegate = self

        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .gray
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
        
        self.view.addSubview(trackLikeButton)
        trackLikeButton.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view.frame.width / 10 - 12)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        })
        trackLikeButton.setImage(UIImage(named: "heartActive"), for: .normal)
        
        self.view.addSubview(trackSpeedButton)
        trackSpeedButton.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view.frame.width / 4)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        })
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
                }
                
                if self.currentTrackID != ob.id {
                    self.currentTrackID = ob.id
                    self.trackInfo.trackInfo.emitter?.send(event: TrackInfoEvent.updateTrack(id: self.currentTrackID))
                }
                
                
				let channel = ob.author
				let title = ob.name

				self.miniPlayer.trackAuthorLabel.text = channel
				self.miniPlayer.trackNameLabel.text = title
				self.mainPlayer.channelNameLabel.text = channel
				self.mainPlayer.trackNameLabel.text = title
				if let url = ob.imageURL {
					self.mainPlayer.coverImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: { (img, error, type, url) in
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
		self.mainPlayer.coverImageView.image = nil

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
    
    @objc func trackSpeedButtonTouched()
    {
        let speedAlert = UIAlertController(title: "The playback speed of audio".localized, message: nil, preferredStyle: .actionSheet)
        speedAlert.view.tintColor = AppColor.Element.redBlur.withAlphaComponent(1)

        for speed in speeds {
            speedAlert.addAction(UIAlertAction(title: speed.text, style: .default, handler: { _ in
                self.change(speed: speed.value)
            }))
        }

        speedAlert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(speedAlert, animated: true, completion: nil)
    }
    
    func change(speed: Double) {
        // TODO: change audio speed
        
    }
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}

extension PlayerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if viewController is PlaylistViewController {
			return mainPlayer
		}
        
        if viewController is MainPlayerViewController {
            return trackInfo
        }
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if viewController is MainPlayerViewController {
			return playlist
		}
        
        if viewController is TrackInfoViewController {
            return mainPlayer
        }
		
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
