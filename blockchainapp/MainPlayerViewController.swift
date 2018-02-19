//
//  MainPlayerViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer
import AssistantKit
import MarqueeLabel

class MainPlayerViewController: UIViewController {
	
	let underblurimageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
		imageView.isUserInteractionEnabled = false
		
		return imageView
	}()
	let coverImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 7
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
		
		imageView.isUserInteractionEnabled = false
		
		return imageView
	}()
	var squareConstraint: LayoutConstraint?
	var landscapeConstraint: LayoutConstraint?
	let shadowLayer: CALayer = {
		let layer = CALayer()
		
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize.zero
		layer.shadowRadius = 5.0
		layer.shadowOpacity = 0.3
		layer.shouldRasterize = true
		
		return layer
	}()

	let trackProgressView: TimedSlider = TimedSlider(frame: CGRect.zero)
	let channelNameLabel: MarqueeLabel = {
		let label = MarqueeLabel(frame: CGRect.zero, duration: 16.0, fadeLength: 16)
		label.font = AppFont.Title.mid
		label.textColor = AppColor.Title.dark
		label.textAlignment = .center
		return label
	}()
	let trackNameLabel: MarqueeLabel = {
		let label = MarqueeLabel(frame: CGRect.zero, duration: 16.0, fadeLength: 16)
		label.font = AppFont.Title.midBold
		label.textColor = AppColor.Title.dark
		label.textAlignment = .center
		return label
	}()
	let playButton: UIButton = {
		let button = UIButton()
		button.setBackgroundImage(UIColor.red.img(), for: .normal)
		button.setBackgroundImage(UIColor.red.withAlphaComponent(0.7).img(), for: .highlighted)
		button.setImage(UIImage(named: "playerPlay"), for: .normal)
		button.setImage(UIImage(named: "playerPause"), for: .selected)
		button.adjustsImageWhenHighlighted = false
		button.layer.cornerRadius = Device.screen == .inches_4_0 ? 27.5 : 35
		button.layer.masksToBounds = true
		button.snp.makeConstraints({ (make) in
			make.width.equalTo(button.snp.height)
		})
		return button
	}()
	let trackChangeButtons: (next: UIButton, prev: UIButton) = {
		let arr = [UIButton(), UIButton()]
		arr.forEach({ (button) in
			button.layer.cornerRadius = Device.screen == .inches_4_0 ? 22.5 : 30
            button.imageView?.contentMode = .scaleAspectFit
//            button.layer.masksToBounds = true
			button.setBackgroundImage(AppColor.Element.tomato.withAlphaComponent(0.1).img(), for: .highlighted)
			button.snp.makeConstraints({ (make) in
				make.width.equalTo(button.snp.height)
			})
		})
		
		arr.first!.setImage(UIImage(named: "nextInactive"), for: .normal)
		arr.last!.setImage(UIImage(named: "prevInactive"), for: .normal)
		
		return (next: arr.first!, prev: arr.last!)
	}()
	
	let trackSeekButtons: (forw: UIButton, backw: UIButton) = {
		let arr = [UIButton(), UIButton()]
		arr.forEach({ (button) in
            button.layer.cornerRadius = Device.screen == .inches_4_0 ? 22.5 : 30
            button.imageView?.contentMode = .scaleAspectFit
//            button.layer.masksToBounds = true
			button.setBackgroundImage(AppColor.Element.tomato.withAlphaComponent(0.1).img(), for: .highlighted)
			button.snp.makeConstraints({ (make) in
				make.width.equalTo(button.snp.height)
			})
		})
		
		arr.first!.setImage(UIImage(named: "playerForw"), for: .normal)
		arr.last!.setImage(UIImage(named: "playerBackw"), for: .normal)
		
		return (forw: arr.first!, backw: arr.last!)
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		viewInitialize()
    }
	
	func viewInitialize() {
		
		self.view.backgroundColor = UIColor.white
		
		underblurimageView.image = UIImage(named: "channelPrevievImg")
		coverImageView.image = UIImage(named: "channelPrevievImg")
		
		self.view.addSubview(underblurimageView)
		underblurimageView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
		}
		
		let blur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
		self.view.addSubview(blur)
		blur.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		blur.contentView.addSubview(trackProgressView)

		let imageSpacer = UIView()
		blur.contentView.addSubview(imageSpacer)
		imageSpacer.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(52)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalTo(self.trackProgressView.snp.top)
		}
        trackProgressView.setContentHuggingPriority(.init(999), for: .horizontal)
		
		imageSpacer.addSubview(coverImageView)
		coverImageView.snp.makeConstraints { (make) in
			
			make.centerY.equalToSuperview()
			
			make.right.equalToSuperview().inset(30)
			make.left.equalToSuperview().inset(30)
			self.squareConstraint = make.height.equalTo(coverImageView.snp.width).multipliedBy(1.0).constraint.layoutConstraints.first
			self.landscapeConstraint = make.height.equalTo(coverImageView.snp.width).multipliedBy(9.0/16).constraint.layoutConstraints.first
			
			
			make.top.equalTo(underblurimageView.snp.top)
			make.size.equalTo(underblurimageView.snp.size)
		}
		
		let volumeSlider: MPVolumeView = {
			let slider = MPVolumeView()
			slider.setMinimumVolumeSliderImage(AppColor.Element.subscribe.img(), for: .normal)
			slider.setMaximumVolumeSliderImage(AppColor.Element.subscribe.withAlphaComponent(0.2).img(), for: .normal)
			slider.showsRouteButton = false
			return slider
		}()
		
		let minVol = UIImageView(image: UIImage(named: "volMin"))
		let maxVol = UIImageView(image: UIImage(named: "volMax"))
		
		blur.contentView.addSubview(minVol)
		minVol.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(30)
		}
		
		blur.contentView.addSubview(volumeSlider)
		volumeSlider.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().inset(Device.screen == .inches_4_0 ? 40 : 56)
			make.left.equalTo(minVol.snp.right).inset(-8)
			make.centerY.equalTo(minVol)
			make.height.equalTo(20)
		}
        volumeSlider.setContentHuggingPriority(.init(999), for: .horizontal)
		
		blur.contentView.addSubview(maxVol)
		maxVol.snp.makeConstraints { (make) in
			make.left.equalTo(volumeSlider.snp.right).inset(-8)
			make.right.equalToSuperview().inset(31)
			make.centerY.equalTo(volumeSlider)
		}
		
		blur.contentView.addSubview(playButton)
		playButton.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.bottom.equalTo(volumeSlider.snp.top).inset(Device.screen == .inches_4_0 ? -15 : -20)
			
			make.width.equalTo(Device.screen == .inches_4_0 ? 55 : 70)
		}
		
		blur.contentView.addSubview(trackSeekButtons.backw)
		trackSeekButtons.backw.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.right.equalTo(playButton.snp.left).inset(-12)//Device.screen == .inches_4_0 ? -8 : -12)
			
			make.width.equalTo(playButton.snp.width).inset(10)
		}
		
		blur.contentView.addSubview(trackSeekButtons.forw)
		trackSeekButtons.forw.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.left.equalTo(playButton.snp.right).inset(-12)//Device.screen == .inches_4_0 ? -8 : -12)
			make.width.equalTo(playButton.snp.width).inset(10)
		}
		
		blur.contentView.addSubview(trackChangeButtons.next)
		trackChangeButtons.next.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.left.equalTo(trackSeekButtons.forw.snp.right).inset(-12)//Device.screen == .inches_4_0 ? -8 : -2)
			make.width.equalTo(playButton.snp.width).inset(10)
		}
		
		blur.contentView.addSubview(trackChangeButtons.prev)
		trackChangeButtons.prev.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.right.equalTo(trackSeekButtons.backw.snp.left).inset(-12)//Device.screen == .inches_4_0 ? -8 : -2)
			make.width.equalTo(playButton.snp.width).inset(10)
		}
		
		blur.contentView.addSubview(trackNameLabel)
		trackNameLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(playButton.snp.top).inset(Device.screen == .inches_4_0 ? -10 : -20)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
		trackNameLabel.text = "i love swift! i love swift! i love swift! i love swift! i love swift!"
		
		blur.contentView.addSubview(channelNameLabel)
		channelNameLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.bottom.equalTo(trackNameLabel.snp.top)
		}
		channelNameLabel.text = "i love swift! i love swift! i love swift! i love swift! i love swift!"
		
		trackProgressView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(33)
			make.right.equalToSuperview().inset(33)
			make.bottom.equalTo(channelNameLabel.snp.top).inset(-7)
		}
		
		trackProgressView.addTarget(self, action: #selector(seek), for: .valueChanged)
		playButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
		trackChangeButtons.next.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
		trackChangeButtons.prev.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
		trackSeekButtons.backw.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
		trackSeekButtons.forw.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
	}
	
	@objc func seek() {
		AudioController.main.make(command: .seek(progress: Double(self.trackProgressView.slider.value)))
	}
	
	@objc func buttonPressed(sender: UIButton) {
		var command = AudioCommand.play(id: nil)
		if sender == playButton {
			if playButton.isSelected {
				command = .pause
			} else {
				command = .play(id: nil)
			}
		} else if sender == self.trackChangeButtons.next {
			command = .next
		} else if sender == self.trackChangeButtons.prev {
			command = .prev
		} else if sender == self.trackSeekButtons.backw {
			command = .seekBackward
		} else if sender == self.trackSeekButtons.forw {
			command = .seekForward
		}
		
		AudioController.main.make(command: command)
	}
	
	func setPicture(image: UIImage?) {
		self.underblurimageView.image = image
		self.coverImageView.image = image

		guard let image = image else {
			return
		}

		let isSquare = image.size.width / image.size.height - 1.0 < 0.3
		

		self.squareConstraint?.isActive = isSquare
		self.landscapeConstraint?.isActive = !isSquare

		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
//		coverImageView.snp.updateConstraints { (make) in
//			make.width.equalTo(coverImageView.snp.height).multipliedBy(1.0)
//		}
//		self.squareConstraint?.isActive = true
//		self.landscapeConstraint?.isActive = false
		
		self.view.layoutIfNeeded()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.shadowLayer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: underblurimageView.frame.width, height: underblurimageView.frame.height)), cornerRadius: 7).cgPath
		self.shadowLayer.frame = self.underblurimageView.frame
		self.channelNameLabel.fadeLength = 16
		self.trackNameLabel.fadeLength = 16
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
