//
//  Followself.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 14/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class FollowButton: UIButton {
	convenience init() {
		self.init(frame: CGRect.zero)
		
		self.layer.cornerRadius = 6
		self.layer.borderColor = AppColor.Element.subscribe.cgColor
		self.layer.borderWidth = 1
		self.layer.masksToBounds = true
		self.setBackgroundImage(AppColor.Element.subscribe.img(), for: .normal)
		self.setBackgroundImage(UIColor.white.img(), for: .selected)
		self.setTitle("follow".localizedCapitalized, for: .normal)
		self.setTitle("following".localizedCapitalized, for: .selected)
		self.setTitleColor(UIColor.white, for: .normal)
		self.setTitleColor(AppColor.Element.subscribe, for: .selected)
		self.contentEdgeInsets.left = 12
		self.contentEdgeInsets.right = 12
		self.titleLabel?.font = AppFont.Button.mid
		
		self.snp.makeConstraints { (make) in
			make.height.equalTo(32)
		}
	}
}
