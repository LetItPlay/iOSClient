//
//  Buttons.swift
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
		self.setTitle("Follow".localized, for: .normal)
		self.setTitle("Following".localized, for: .selected)
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

class ProfileButton: UIButton {
    convenience init(title: String) {
        self.init(frame: CGRect.zero)
        self.titleLabel?.font = AppFont.Button.mid
        self.setTitleColor(.red, for: .normal)
        self.setTitle(title, for: .normal)
        self.titleLabel?.textAlignment = .center
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        self.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 7, 20)
    }
}
