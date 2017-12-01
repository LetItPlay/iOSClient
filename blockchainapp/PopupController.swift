//
//  PlayerController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 28/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import LNPopupController
import SnapKit

class PopupController: LNPopupCustomBarViewController {
	init() {
		super.init(nibName: nil, bundle: nil)
		self.popupBar.marqueeScrollEnabled = true
		self.popupBar.progressViewStyle = .bottom
		
		self.popupBar.titleTextAttributes = [NSAttributedStringKey.font.rawValue: AppFont.Text.mid, NSAttributedStringKey.foregroundColor.rawValue: AppColor.Title.gray]
		self.popupBar.subtitleTextAttributes = [NSAttributedStringKey.font.rawValue: AppFont.Title.sml, NSAttributedStringKey.foregroundColor.rawValue: AppColor.Title.gray]
		
		self.popupBar.layoutSubviews()
		
		let button = UIButton()
		button.setImage(UIImage.init(named: "playInacteive"), for: .normal)
		button.snp.makeConstraints { (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		}
		
		let button2 = UIButton()
		button2.setImage(UIImage.init(named: "nextInacteive"), for: .normal)
		button2.snp.makeConstraints { (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		}
		
		self.popupItem.rightBarButtonItems = [button, button2].map({UIBarButtonItem.init(customView: $0)})		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
