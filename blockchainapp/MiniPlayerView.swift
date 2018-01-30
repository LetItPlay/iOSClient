//
//  MiniPlayerView.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import MarqueeLabel
import SnapKit

protocol MiniPlayerPresentationDelegate: class {
	func playerTapped()
}

class MiniPlayerView: UITabBar {
	
	weak var presentationDelegate: MiniPlayerPresentationDelegate?
	
	let trackImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.isUserInteractionEnabled = false
		
		imageView.snp.makeConstraints({ (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		})
		imageView.layer.cornerRadius = 6
		imageView.layer.masksToBounds = true
		
		return imageView
	}()
	
	let trackNameLabel: MarqueeLabel = {
		let label = MarqueeLabel(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 120, height: 40)), rate: 20.0, fadeLength: 16)
		label.textColor = AppColor.Title.dark
		label.font = AppFont.Title.sml
		return label
	}()
	
	let trackAuthorLabel: MarqueeLabel = {
		let label = MarqueeLabel(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 120, height: 40)), rate: 20.0, fadeLength: 16)
		label.textColor = AppColor.Title.dark
		label.font = AppFont.Text.mid
		return label
	}()
	
	let progressView: UIProgressView = {
		let progressView = UIProgressView(progressViewStyle: .default)
		progressView.progressTintColor = AppColor.Element.subscribe
		progressView.trackTintColor = AppColor.Element.subscribe.withAlphaComponent(0.2)
		return progressView
	}()
	
	let playButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "playInactive"), for: .normal)
		button.setImage(UIImage(named: "stopInactive"), for: .selected)
		button.setBackgroundImage(UIImage.init(named: "touchBg"), for: .highlighted)
		button.snp.makeConstraints({ (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		})
		return button
	}()
	
	let nextButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage.init(named: "popupNextInactive"), for: .normal)
		button.setBackgroundImage(UIImage.init(named: "touchBg"), for: .highlighted)
		button.snp.makeConstraints({ (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		})
		return button
	}()
	
	convenience init() {
		self.init(frame: CGRect.zero)
		
		self.snp.makeConstraints { (make) in
			make.height.equalTo(72)
		}
		
		self.addSubview(nextButton)
		nextButton.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(16)
			make.centerY.equalToSuperview().inset(-4)
		}
		
		self.addSubview(playButton)
		playButton.snp.makeConstraints { (make) in
			make.right.equalTo(nextButton.snp.left).inset(-16)
			make.centerY.equalTo(nextButton)
		}
		
		self.addSubview(progressView)
		progressView.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().inset(6)
		}
		
		self.addSubview(trackImageView)
		trackImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.centerY.equalToSuperview().inset(-4)
		}
		
		self.addSubview(trackAuthorLabel)
		trackAuthorLabel.snp.makeConstraints { (make) in
			make.left.equalTo(trackImageView.snp.right).inset(-16)
			make.right.equalTo(playButton.snp.left).inset(-16)
			make.top.equalToSuperview().inset(12)
		}
		
		self.addSubview(trackNameLabel)
		trackNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(trackImageView.snp.right).inset(-16)
			make.right.equalTo(playButton.snp.left).inset(-16)
			make.top.equalTo(trackAuthorLabel.snp.bottom).inset(-4)
		}
		
		progressView.progress = 0.4
		trackImageView.backgroundColor = .red
		trackNameLabel.text = "123 123 123123 123 123123 123 123123 123 123"
		trackAuthorLabel.text = "123 123 123123 123 123123 123 123123 123 123"

		let tap = UITapGestureRecognizer(target: self, action: #selector(playerOpen(gesture:)))
		self.addGestureRecognizer(tap)
		
//		let swipe = UISwipeGestureRecognizer(target: self, action: #selector(playerOpen(gesture:)))
//		self.addGestureRecognizer(swipe)
//
//		let pan = UIPanGestureRecognizer(target: self, action: #selector(playerOpen(gesture:)))
//		self.addGestureRecognizer(pan)
	}
	
	@objc func playerOpen(gesture: UIGestureRecognizer) {
		if let pan = gesture as? UIPanGestureRecognizer {
			switch pan.state {
				case .began:
					self.presentationDelegate?.playerTapped()
				default:
					break
			}
		} else {
			self.presentationDelegate?.playerTapped()
		}
	}
	
	
}
