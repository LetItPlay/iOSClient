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

class MiniPlayerView: UIButton {
	
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
		
		return progressView
	}()
	
	let playButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "playInactive"), for: .normal)
		button.setImage(UIImage(named: "stopInactive"), for: .selected)
		button.setBackgroundImage(UIImage.init(named: "touchBg"), for: .normal)
		return button
	}()
	
	let nextButton: UIButton = {
		let button = UIButton()
		
		return button
	}()
	
	convenience init() {
		self.init(frame: CGRect.zero)
		
	}
	
}
