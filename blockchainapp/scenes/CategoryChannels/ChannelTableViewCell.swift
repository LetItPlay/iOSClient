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
import SDWebImage

class ChannelTableViewCell: UITableViewCell, StandartTableViewCell {
    var event: ((String, [String : Any]?) -> Void)?
	
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
	
	let followButton = FollowButton()
	
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
    
    static func height(data: Any, width: CGFloat) -> CGFloat {
        return self.height
    }
    
    func fill(data: Any?) {
        guard let viewModel = data as? MediumChannelViewModel else {
            return
        }
        
        self.fill(channel: viewModel)
    }
    
    func fill(channel: MediumChannelViewModel) {
        DispatchQueue.main.async {
            
            self.channelTitle.text = channel.name
            self.subs.set(text: channel.subscriptionCount)
            self.plays.set(text: channel.tracksCount)
            
            self.followButton.set(title: channel.getMainButtonTitle())
            
            self.tagsList.removeAllTags()
            let tags = channel.tags.map({$0}).prefix(4)
            if tags.count != 0 {
                self.tagsList.addTags(tags.map({$0.uppercased()}))
                self.noTagsView.isHidden = true
                self.tagsList.isHidden = false
            } else {
                self.noTagsView.isHidden = false
                self.tagsList.isHidden = true
            }
            
            if let urlString = channel.imageURL {
                self.channelImageView.sd_setImage(with: urlString, placeholderImage: UIImage(named: "channelPreviewImg"), options: SDWebImageOptions.refreshCached, completed: nil)
            } else {
                self.channelImageView.image = UIImage(named: "channelPreviewImg")
            }
        }
    }
	
	@objc func subPressed() {
        self.followButton.isSelected = !self.followButton.isSelected
        self.event!("onFollow", nil)
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.selectionStyle = .none
		followButton.addTarget(self, action: #selector(subPressed), for: .touchUpInside)
		
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
		
		self.contentView.addSubview(followButton)
		followButton.snp.makeConstraints { (make) in
			make.left.equalTo(channelTitle)
			make.top.equalTo(channelTitle.snp.bottom).inset(-8)
			make.height.equalTo(32)
		}
		
        tagsList.delegate = self
		self.contentView.addSubview(tagsList)
		tagsList.snp.makeConstraints { (make) in
            self.tagsConstraint = make.top.equalTo(followButton.snp.bottom).inset(-8).constraint.layoutConstraints.first!
			make.left.equalTo(channelTitle)
			make.right.equalToSuperview().inset(16)
		}
		
		self.contentView.addSubview(subs)
		subs.snp.makeConstraints { (make) in
			make.top.equalTo(tagsList.snp.bottom).inset(-4)
			make.left.equalTo(channelTitle)
			make.bottom.equalTo(channelImageView).inset(4)
		}
		
//        self.contentView.addSubview(plays)
//        plays.snp.makeConstraints { (make) in
//            make.left.equalTo(subs.snp.right).inset(-10)
//            make.bottom.equalTo(channelImageView).inset(4)
//        }
	}
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        // for 3 lines of text in title
        if self.followButton.frame.origin.y > 70
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

extension ChannelTableViewCell: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        self.event!("onTag", ["text" : title])
    }
}
