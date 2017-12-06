//
//  ChannelHeaderView.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 27/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import TagListView

class ChannelHeaderView: UIView {

	let channelImageView: UIImageView = {
		let imgView = UIImageView()
		imgView.contentMode = .scaleToFill
		return imgView
	}()
	
	let channelIconView: UIImageView = {
		let imgView = UIImageView()
		imgView.layer.cornerRadius = 20
		imgView.contentMode = .scaleAspectFill
		imgView.snp.makeConstraints({ (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		})
		return imgView
	}()
	
	let subsView: IconedLabel = IconedLabel.init(type: IconLabelType.subs)
	let followButton: UIButton = {
		let button = UIButton()
		button.setTitle("follow".localizedUppercase, for: .normal)
		button.setTitle("following".localizedUppercase, for: .selected)
		button.titleLabel?.font = AppFont.Button.mid
		button.setBackgroundImage(UIColor.red.img(), for: .normal)
		button.layer.cornerRadius = 6
		button.layer.borderColor = AppColor.Element.subscribe.cgColor
		button.layer.borderWidth = 1
		
		button.snp.makeConstraints({ (make) in
			make.height.equalTo(32)
		})
		return button
	}()
	
	let channelTitleView: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.lineBreakMode = .byTruncatingTail
		return label
	}()
	
	let infoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 6
		label.font = AppFont.Text.mid
		label.textColor = AppColor.Title.dark
		return label
	}()
	
	let tagListView = TagListView()
	
	var topImgCnstr: NSLayoutConstraint!
	var leftImgCnstr: NSLayoutConstraint!
	var rightImgCnstr: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.viewInitialize(width: frame.width)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func viewInitialize(width: CGFloat) {
		self.addSubview(channelImageView)
		channelImageView.snp.makeConstraints { (make) in
			self.topImgCnstr = make.top.equalToSuperview().constraint.layoutConstraints.first!
			self.leftImgCnstr = make.left.equalToSuperview().constraint.layoutConstraints.first!
			self.rightImgCnstr = make.right.equalToSuperview().constraint.layoutConstraints.first!
			make.height.equalTo(width*CGFloat(16)/CGFloat(9))
		}
		
		let view = UIView()
		view.backgroundColor = AppColor.Element.redBlur
		self.addSubview(view)
		view.snp.makeConstraints { (make) in
			make.top.equalTo(channelImageView.snp.bottom)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(52)
		}
		
		view.addSubview(channelIconView)
		channelIconView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
		}
		
		view.addSubview(subsView)
		subsView.snp.makeConstraints { (make) in
			make.left.equalTo(channelIconView.snp.right).inset(-16)
			make.centerY.equalToSuperview()
		}
		
		view.addSubview(followButton)
		followButton.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(-16)
			make.centerY.equalToSuperview()
		}

		self.addSubview(channelTitleView)
		channelTitleView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(view.snp.bottom).inset(12)
			make.right.equalToSuperview().inset(16)
		}
		
		self.addSubview(infoLabel)
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(channelTitleView.snp.bottom).inset(14)
			make.left.equalToSuperview().inset(16)
		}
		
		self.addSubview(tagListView)
		tagListView.snp.makeConstraints { (make) in
			
		}
	}
	
	static func height(width: CGFloat) -> CGFloat {
		
		return 0.0
	}
}
