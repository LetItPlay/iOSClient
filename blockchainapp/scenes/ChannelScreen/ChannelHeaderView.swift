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
import SDWebImage

class ChannelHeaderView: UIView {
    
    public var onShared: (() -> Void)?
	
	let channelImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white
		return imageView
	}()
	
	let channelIconView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 20
		imageView.layer.masksToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.snp.makeConstraints({ (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		})
        imageView.image = UIImage(named: "channelPreviewImg")
		return imageView
	}()
	
	let subsView: IconedLabel = IconedLabel.init(type: IconLabelType.subs)
    
    var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "sharedInactive"), for: .normal)
        return button
    }()
    
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
	
	let channelTitleLabel: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 3
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
		
        self.backgroundColor = .white
        
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
        
        shareButton.addTarget(self, action: #selector(self.shareButtonTouched), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(followButton)
            make.right.equalTo(followButton.snp.left).inset(-14)
        }

		self.addSubview(channelTitleLabel)
		channelTitleLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(view.snp.bottom).inset(-12)
			make.right.equalToSuperview().inset(16)
		}
		
		self.addSubview(infoLabel)
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(channelTitleLabel.snp.bottom).inset(-14)
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
	}
    
    func fill(channel: FullChannelViewModel, width: CGFloat) -> CGFloat {
        
        channelTitleLabel.text = channel.name
        infoLabel.text = ""
        subsView.set(text: channel.subscriptionCount)
        
        if let iconUrl = channel.imageURL {
            
            channelIconView.sd_setImage(with: iconUrl, placeholderImage: UIImage(named: "channelPreviewImg"), options: SDWebImageOptions.refreshCached, completed: {[weak self] (image, error, type, url) in
                self?.channelImageView.image = image
            })
            channelIconView.backgroundColor = .white
            channelImageView.snp.makeConstraints { (make) in
                make.height.equalTo(width*CGFloat(6)/CGFloat(16))
            }
        } else {
            channelImageView.snp.makeConstraints { (make) in
                make.height.equalTo(0)
            }
            channelImageView.image = nil
            channelIconView.image = nil
            channelIconView.backgroundColor = .white
        }
        
        self.tagListView.removeAllTags()
        self.tagListView.addTags(channel.tags.map({$0.uppercased()}))
        
        return self.frame.origin.y + self.frame.height
    }
    
    @objc func shareButtonTouched() {
        self.onShared!()
    }
}
