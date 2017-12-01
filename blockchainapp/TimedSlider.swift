//
//  TimedSlider.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 01/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class CustomSlider: UISlider {
	override func trackRect(forBounds bounds: CGRect) -> CGRect {
		var frame = bounds
		frame.size.height = 4
		frame.origin.y = self.frame.height / 2 - frame.size.height
		return frame
	}
}

class TimedSlider: UIControl {

	let slider: UISlider = {
		let slider = CustomSlider.init(frame: CGRect.zero)
		slider.setThumbImage(AppColor.Element.subscribe.circle(diameter: 14), for: .normal)
		slider.setThumbImage(AppColor.Element.subscribe.circle(diameter: 20), for: .highlighted)
		slider.minimumTrackTintColor = AppColor.Element.subscribe
		slider.maximumTrackTintColor = AppColor.Element.subscribe.withAlphaComponent(0.2)
		return slider
	}()
	
	let trackProgressLabels: (start: UILabel, fin: UILabel) = {
		let arr = [UILabel(), UILabel()]
		arr.forEach({ (label) in
			label.font = AppFont.Title.info
			label.textColor = AppColor.Title.lightGray
			
		})
		return (start: arr.first!, fin: arr.last!)
	}()
	
	var leftConstr: NSLayoutConstraint!
	var rightConstr: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.addSubview(slider)
		slider.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().inset(12)
		}
		
		self.addSubview(trackProgressLabels.fin)
		trackProgressLabels.fin.snp.makeConstraints { (make) in
			self.rightConstr = make.top.equalTo(slider.snp.bottom).inset(0).constraint.layoutConstraints.first!
			make.right.equalToSuperview()
		}
		
		self.addSubview(trackProgressLabels.start)
		trackProgressLabels.start.snp.makeConstraints { (make) in
			self.leftConstr = make.top.equalTo(slider.snp.bottom).inset(0).constraint.layoutConstraints.first
			make.left.equalToSuperview()
		}
		
		self.slider.addTarget(self, action: #selector(sliderChanged(sender:)), for: .valueChanged)
	}
	
	@objc func sliderChanged(sender: UISlider) {
		let dist = self.slider.frame.width * CGFloat(self.slider.value)
		
		let startFrame = trackProgressLabels.start.frame
		let finFrame = trackProgressLabels.fin.frame
		let modelPoint = CGPoint.init(x: dist, y: self.frame.height - 10)

		self.sendActions(for: .valueChanged)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
