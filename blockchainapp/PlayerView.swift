//
//  PlayerView.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 01/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import MarqueeLabel
import MediaPlayer
import LNPopupController

class PlayerView: UIView {
	
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
		button.layer.cornerRadius = 35
		button.layer.masksToBounds = true
		button.snp.makeConstraints({ (make) in
			make.width.equalTo(70)
			make.height.equalTo(70)
		})
		return button
	}()
	let trackChangeButtons: (next: UIButton, prev: UIButton) = {
		let arr = [UIButton(), UIButton()]
		arr.forEach({ (button) in
			button.layer.cornerRadius = 30
			button.layer.masksToBounds = true
			button.setBackgroundImage(AppColor.Element.tomato.withAlphaComponent(0.1).img(), for: .highlighted)
			button.snp.makeConstraints({ (make) in
				make.width.equalTo(60)
				make.height.equalTo(60)
			})
		})
		
		arr.first!.setImage(UIImage(named: "nextInactive"), for: .normal)
		arr.last!.setImage(UIImage(named: "prevInactive"), for: .normal)
		
		return (next: arr.first!, prev: arr.last!)
	}()
	
	let trackSeekButtons: (forw: UIButton, backw: UIButton) = {
		let arr = [UIButton(), UIButton()]
		arr.forEach({ (button) in
			button.layer.cornerRadius = 30
			button.layer.masksToBounds = true
			button.setBackgroundImage(AppColor.Element.tomato.withAlphaComponent(0.1).img(), for: .highlighted)
			button.snp.makeConstraints({ (make) in
				make.width.equalTo(60)
				make.height.equalTo(60)
			})
		})
		
		arr.first!.setImage(UIImage(named: "playerForw"), for: .normal)
		arr.last!.setImage(UIImage(named: "playerBackw"), for: .normal)
		
		return (forw: arr.first!, backw: arr.last!)
	}()
	
	let volumeSlider: MPVolumeView = {
		let slider = MPVolumeView()
		slider.setMinimumVolumeSliderImage(AppColor.Element.subscribe.img(), for: .normal)
		slider.setMaximumVolumeSliderImage(AppColor.Element.subscribe.withAlphaComponent(0.2).img(), for: .normal)
		slider.showsRouteButton = false
//		slider.minimumTrackTintColor = AppColor.Element.subscribe
//		slider.maximumTrackTintColor = AppColor.Element.subscribe.withAlphaComponent(0.2)
		return slider
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		viewInitialize()
		
		self.trackProgressView.trackProgressLabels.fin.text = "0:00"
		self.trackProgressView.trackProgressLabels.start.text = "-0:00"
	}
	
	func viewInitialize() {
		
		self.backgroundColor = UIColor.white
		
		underblurimageView.image = UIImage(named: "channelPrevievImg")
		coverImageView.image = UIImage(named: "channelPrevievImg")
		
		underblurimageView.isUserInteractionEnabled = false
		
		addSubview(underblurimageView)
		underblurimageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(75)
			make.left.equalToSuperview().inset(35)
			make.right.equalToSuperview().inset(35)
			make.width.equalTo(underblurimageView.snp.height)
		}
		
		let blur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
		addSubview(blur)
		blur.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		blur.layer.addSublayer(shadowLayer)
		
		blur.contentView.addSubview(coverImageView)
		coverImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(70)
			make.left.equalToSuperview().inset(30)
			make.right.equalToSuperview().inset(30)
			make.width.equalTo(coverImageView.snp.height)
		}
		
		blur.contentView.addSubview(trackProgressView)
		trackProgressView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(33)
			make.right.equalToSuperview().inset(33)
			make.top.equalTo(coverImageView.snp.bottom).inset(-12)
		}
		
		blur.contentView.addSubview(channelNameLabel)
		channelNameLabel.snp.makeConstraints { (make) in
			make.top.equalTo(coverImageView.snp.bottom).inset(-43)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
		channelNameLabel.text = "i love swift! i love swift! i love swift! i love swift! i love swift!"
		
		blur.contentView.addSubview(trackNameLabel)
		trackNameLabel.snp.makeConstraints { (make) in
			make.top.equalTo(channelNameLabel.snp.bottom)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
		trackNameLabel.text = "i love swift! i love swift! i love swift! i love swift! i love swift!"
		
		blur.contentView.addSubview(playButton)
		playButton.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(trackNameLabel.snp.bottom).inset(-20)
		}
		
		blur.contentView.addSubview(trackSeekButtons.backw)
		trackSeekButtons.backw.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.right.equalTo(playButton.snp.left).inset(-12)
		}
		
		blur.contentView.addSubview(trackSeekButtons.forw)
		trackSeekButtons.forw.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.left.equalTo(playButton.snp.right).inset(-12)
		}
		
		blur.contentView.addSubview(trackChangeButtons.next)
		trackChangeButtons.next.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.left.equalTo(trackSeekButtons.forw.snp.right).inset(-2)
		}
		
		blur.contentView.addSubview(trackChangeButtons.prev)
		trackChangeButtons.prev.snp.makeConstraints { (make) in
			make.centerY.equalTo(playButton)
			make.right.equalTo(trackSeekButtons.backw.snp.left).inset(-2)
		}
		
		let minVol = UIImageView(image: UIImage(named: "volMin"))
		let maxVol = UIImageView(image: UIImage(named: "volMax"))
		
		blur.contentView.addSubview(minVol)
		minVol.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(30)
		}
		
		blur.contentView.addSubview(volumeSlider)
		volumeSlider.snp.makeConstraints { (make) in
			make.top.equalTo(playButton.snp.bottom).inset(-25)
			make.left.equalTo(minVol.snp.right).inset(-8)
			make.centerY.equalTo(minVol)
			make.height.equalTo(20)
		}
		
		blur.contentView.addSubview(maxVol)
		maxVol.snp.makeConstraints { (make) in
			make.left.equalTo(volumeSlider.snp.right).inset(-8)
			make.right.equalToSuperview().inset(31)
			make.centerY.equalTo(volumeSlider)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.shadowLayer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: underblurimageView.frame.width, height: underblurimageView.frame.height)), cornerRadius: 7).cgPath
		self.shadowLayer.frame = self.underblurimageView.frame
		self.channelNameLabel.fadeLength = 16
		self.trackNameLabel.fadeLength = 16
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
//	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//		return true
//	}
//
//	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//		let funcElementPoints: [UIView] = [
//			trackProgressView, playButton, trackSeekButtons.backw,
//			trackSeekButtons.forw, trackChangeButtons.next, trackChangeButtons.prev,
//			volumeSlider]
//		for view in funcElementPoints {
//			if view.frame.contains(self.convert(point, to: view)) {
//				return view
//			}
//		}
//
//		if point.y < self.frame.height/2 {
//			return nil
//		} else {
//			return super.hitTest(point, with: event)
//		}
//	}
}
