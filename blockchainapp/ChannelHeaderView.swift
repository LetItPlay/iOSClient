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

protocol ChannelsHeaderDelegate: class {
	func set(height: CGFloat)
}

class ChannelHeaderView: UIView {

	weak var delegate: ChannelsHeaderDelegate?
	
	let channelImageView: UIImageView = {
		let imgView = UIImageView()
		imgView.contentMode = .scaleAspectFill
		imgView.layer.masksToBounds = true
		return imgView
	}()
	
	let channelIconView: UIImageView = {
		let imgView = UIImageView()
		imgView.layer.cornerRadius = 20
		imgView.layer.masksToBounds = true
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
		button.layer.cornerRadius = 6
		button.layer.borderColor = AppColor.Element.subscribe.cgColor
		button.layer.borderWidth = 1
		button.layer.masksToBounds = true
		button.setBackgroundImage(AppColor.Element.subscribe.img(), for: .normal)
		button.setBackgroundImage(UIColor.clear.img(), for: .selected)
		button.setTitle("Follow".localized, for: .normal)
		button.setTitle("Following".localized, for: .selected)
		button.setTitleColor(UIColor.white, for: .normal)
		button.setTitleColor(AppColor.Element.subscribe, for: .selected)
		button.contentEdgeInsets.left = 12
		button.contentEdgeInsets.right = 12
		button.titleLabel?.font = AppFont.Button.mid
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
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 6
		label.font = AppFont.Text.mid
		label.textColor = AppColor.Title.dark
		return label
	}()
	
	let tagListView: TagListView = {
		let taglist = TagListView()
		taglist.borderColor = AppColor.Element.tagColor.withAlphaComponent(0.2)
		taglist.textColor = AppColor.Element.tagColor.withAlphaComponent(0.6)
		taglist.tagBackgroundColor = .white
		taglist.borderWidth = 1
		taglist.cornerRadius = 9
		taglist.marginX = 2
		taglist.marginY = 3
		taglist.paddingX = 6
		taglist.paddingY = 4
		taglist.textFont = AppFont.Title.info
		taglist.clipsToBounds = true
		return taglist
	}()
	
	var topImgCnstr: NSLayoutConstraint!
	var leftImgCnstr: NSLayoutConstraint!
	var rightImgCnstr: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.viewInitialize(width: frame.width)
		self.backgroundColor = .white		
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
//			make.height.equalTo(width*CGFloat(9)/CGFloat(16))
		}
		
		let view = UIView()
		view.backgroundColor = AppColor.Element.redBlur.withAlphaComponent(0.09)
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
			make.right.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
			make.height.equalTo(32)
		}

		self.addSubview(channelTitleView)
		channelTitleView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(view.snp.bottom).inset(-12)
			make.right.equalToSuperview().inset(16)
		}
		
		self.addSubview(infoLabel)
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(channelTitleView.snp.bottom).inset(-14)
			make.right.equalToSuperview().inset(16)
		}
		
		self.addSubview(tagListView)
		tagListView.snp.makeConstraints { (make) in
			make.top.equalTo(infoLabel.snp.bottom).inset(-16)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().inset(26)
		}
		
		let bottomLine = UIView()
		bottomLine.backgroundColor = UIColor.red.withAlphaComponent(0.2)
		bottomLine.layer.masksToBounds = true
		bottomLine.layer.cornerRadius = 1.0
		
		self.addSubview(bottomLine)
		bottomLine.snp.makeConstraints { (make) in
			make.height.equalTo(2)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.bottom.equalToSuperview()
		}
		
		channelTitleView.text = "123 123 123 123 123"
		infoLabel.text = "123 123123 123 123123123 123123123 123 23123 123123 123 123123123 123123123 123 23123 123123 123 123123123 123123123 123 23123 123123 123 123123123 123123123 123 23123 123123 123 123123123 123123123 123 23123 123123 123 123123123 123123123 123 23123 123123 123 123123123 123123123 123 23"
	}
	
	func fill(station: Station, width: CGFloat) -> CGFloat {
		channelTitleView.text = station.name
		infoLabel.text = "No description for this channel"
		subsView.setData(data: Int64(station.subscriptionCount))
		if let iconUrl = station.image.buildImageURL() {
			
			channelIconView.sd_setImage(with: iconUrl, completed: {[weak self] (image, error, type, url) in
				self?.channelImageView.image = image
			})
			channelIconView.backgroundColor = .white
			channelImageView.snp.makeConstraints { (make) in
				make.height.equalTo(width*CGFloat(6)/CGFloat(16))
			}
		} else {
			channelImageView.snp.makeConstraints { (make) in
				make.height.equalTo(0)//width*CGFloat(9)/CGFloat(16))
			}
			channelImageView.image = nil
			channelIconView.image = nil
			channelIconView.backgroundColor = .white
		}
		
		self.tagListView.removeAllTags()
		self.tagListView.addTags(station.getTags().map({$0.uppercased()}))
//		self.layoutIfNeeded()
		
		return self.frame.origin.y + self.frame.height
	}
}
