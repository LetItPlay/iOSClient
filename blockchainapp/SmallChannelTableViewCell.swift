//
//  SmallChannelTableViewCell.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 14/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class SmallChannelTableViewCell: UITableViewCell {

	static let cellID = "SmallChannelCellID"
	static let height: CGFloat = 86.0
	
	let channelImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 30
		imageView.layer.masksToBounds = true
		imageView.snp.makeConstraints { maker in
			maker.width.equalTo(60)
			maker.height.equalTo(60)
		 }
		return imageView
	}()
	
	let channelNameLabel: UILabel = {
		let label = UILabel()
		label.textColor = AppColor.Title.dark
		label.font = AppFont.Title.mid
		return label
	}()
	var followButton: UIButton = FollowButton()
	var dataLabels: [IconLabelType: IconedLabel] = [:]
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(channelImageView)
		channelImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
		}
		
		self.contentView.addSubview(channelNameLabel)
		self.channelNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(channelImageView.snp.right).inset(-10)
			make.top.equalTo(channelImageView).inset(8)
			make.right.equalToSuperview().inset(124)
		}
		
		self.contentView.addSubview(followButton)
		self.followButton.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(16)
		}
		
		let subs = IconedLabel(type: .subs)
		let listens = IconedLabel(type: .listens)
		let indicator = IconedLabel(type: .playingIndicator)
		
		self.contentView.addSubview(subs)
		subs.snp.makeConstraints { (make) in
			make.left.equalTo(channelImageView.snp.right).inset(-10)
			make.bottom.equalTo(channelImageView).inset(7)
		}
		
		self.contentView.addSubview(listens)
		listens.snp.makeConstraints { (make) in
			make.centerY.equalTo(subs)
			make.left.equalTo(subs.snp.right).inset(-10)
		}
		
		self.contentView.addSubview(indicator)
		indicator.snp.makeConstraints { (make) in
			make.centerY.equalTo(subs)
			make.left.equalTo(subs.snp.right).inset(-10)
		}
		
		indicator.isHidden = true
		
		channelImageView.backgroundColor = .red
		channelNameLabel.text = "123 123123"
		subs.setData(data: 123)
		listens.setData(data: 123)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
