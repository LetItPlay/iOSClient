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
	var coverWidthConstraint: LayoutConstraint?
	
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
		
		blur.contentView.addSubview(coverImageView)
		coverImageView.snp.makeConstraints { (make) in
			make.centerY.equalTo(self.view.snp.centerY).dividedBy(2).inset(10 + 20 + 12 + 20)
			
			make.right.equalToSuperview().inset(30)
			make.left.equalToSuperview().inset(30)
			self.coverWidthConstraint = make.width.equalTo(coverImageView.snp.height).constraint.layoutConstraints.first
			
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
			make.bottom.equalToSuperview().inset(56)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
