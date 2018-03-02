//
//  ChannelTableViewCell.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import TagListView
import SnapKit

class ChannelTableViewCell: UITableViewCell {
	
	static let cellID: String = "ChannelCellID"
    static let height: CGFloat = 188.0
    
    var tagsConstraint: NSLayoutConstraint!
	
	let channelImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 9
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let channelTitle: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.mid
		label.textColor = AppColor.Title.dark
		label.numberOfLines = 3
		label.lineBreakMode = .byWordWrapping
		label.setContentHuggingPriority(UILayoutPriority.init(1000), for: .vertical)
		return label
	}()
	
	let subButton: UIButton = {
		let button = UIButton()
		button.layer.cornerRadius = 6
		button.layer.borderColor = AppColor.Element.subscribe.cgColor
		button.layer.borderWidth = 1
		button.layer.masksToBounds = true
		button.setBackgroundImage(AppColor.Element.subscribe.img(), for: .normal)
		button.setBackgroundImage(UIColor.white.img(), for: .selected)
		button.setTitle("Follow".localized, for: .normal)
		button.setTitle("Following".localized, for: .selected)
		button.setTitleColor(UIColor.white, for: .normal)
		button.setTitleColor(AppColor.Element.subscribe, for: .selected)
		button.contentEdgeInsets.left = 12
		button.contentEdgeInsets.right = 12
		button.titleLabel?.font = AppFont.Button.mid
		return button
	}()
	
	let tagsList: TagListView = {
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
	
	let noTagsView: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.mid
		label.textAlignment = .center
		label.textColor = AppColor.Title.light
		return label
	}()
    
	let subs: IconedLabel = IconedLabel(type: IconLabelType.subs)
	let plays: IconedLabel = IconedLabel(type: IconLabelType.tracks)
	
	var subAction: (_ channel: MediumChannelViewModel?) -> Void = { _ in }
    var viewModel: MediumChannelViewModel?
	
	weak var channel: MediumChannelViewModel? = nil {
		didSet {
            self.viewModel = channel
            
			channelTitle.text = self.viewModel?.name
            subs.set(text: (self.viewModel?.subscriptionCount)!)
            plays.set(text: (self.viewModel?.tracksCount)!)
            
            self.subButton.isSelected = (self.viewModel?.isSubscribed)!
            
			self.tagsList.removeAllTags()
			if let tags = self.viewModel?.tags.map({$0}).prefix(4) {
				if tags.count != 0 {
					tagsList.addTags(tags.map({$0.uppercased()}))
					self.noTagsView.isHidden = true
					tagsList.isHidden = false
				} else {
					self.noTagsView.isHidden = false
					self.tagsList.isHidden = true
				}
			} else {
				self.noTagsView.isHidden = false
				self.tagsList.isHidden = true
			}
            if let urlString = self.viewModel?.imageURL {
                channelImageView.sd_setImage(with: urlString)
            } else {
                channelImageView.image = nil
            }
		}
	}
	
	@objc func subPressed() {
		self.subAction(self.channel)
		self.subButton.isSelected = !self.subButton.isSelected
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.selectionStyle = .none
		subButton.addTarget(self, action: #selector(subPressed), for: .touchUpInside)
		
		self.contentView.addSubview(channelImageView)
		channelImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalToSuperview().inset(8)
			make.width.equalTo(164)
			make.height.equalTo(164)
		}
		
		self.contentView.addSubview(channelTitle)
		channelTitle.snp.makeConstraints { (make) in
			make.top.equalTo(channelImageView).inset(4)
			make.left.equalTo(channelImageView.snp.right).inset(-14)
			make.right.equalToSuperview().inset(16)
		}
		
		self.contentView.addSubview(subButton)
		subButton.snp.makeConstraints { (make) in
			make.left.equalTo(channelTitle)
			make.top.equalTo(channelTitle.snp.bottom).inset(-8)
//			make.right.greaterThanOrEqualToSuperview().inset(16)
			make.height.equalTo(32)
		}
		
		self.contentView.addSubview(tagsList)
		tagsList.snp.makeConstraints { (make) in
            self.tagsConstraint = make.top.equalTo(subButton.snp.bottom).inset(-8).constraint.layoutConstraints.first!
			make.left.equalTo(channelTitle)
			make.right.equalToSuperview().inset(16)
		}
		
		self.contentView.addSubview(subs)
		subs.snp.makeConstraints { (make) in
			make.top.equalTo(tagsList.snp.bottom).inset(-4)
			make.left.equalTo(channelTitle)
			make.bottom.equalTo(channelImageView).inset(4)
		}
		
		self.contentView.addSubview(plays)
		plays.snp.makeConstraints { (make) in
			make.left.equalTo(subs.snp.right).inset(-10)
			make.bottom.equalTo(channelImageView).inset(4)
		}
	}
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        // for 3 lines of text in title
        if self.subButton.frame.origin.y > 70
        {
            self.tagsConstraint.constant = 9
        }
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
