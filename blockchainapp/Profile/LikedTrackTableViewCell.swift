//
//  LikedTrackTableViewCell.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 22/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class LikedTrackTableViewCell: UITableViewCell {

	static let cellHeight: CGFloat = 68.0
	static let cellID: String = "LikeTrackCellID"
	
	let trackImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 6
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	let trackNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.textColor = .black
		return label
	}()
	let channelNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor.black.withAlphaComponent(0.6)
		return label
	}()
	let timeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor.black.withAlphaComponent(0.6)
		label.textAlignment = .right
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(trackImageView)
		trackImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
			make.width.equalTo(60)
			make.height.equalTo(60)
		}
		
		self.contentView.addSubview(trackNameLabel)
		trackNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(trackImageView.snp.right).inset(-14)
			make.top.equalTo(trackImageView).inset(10)
			make.right.equalToSuperview().inset(16)
		}
		
		self.contentView.addSubview(channelNameLabel)
		channelNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(trackNameLabel)
			make.top.equalTo(trackNameLabel.snp.bottom).inset(-4)
		}
		
		self.contentView.addSubview(timeLabel)
		timeLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(16)
			make.centerY.equalTo(channelNameLabel)
			make.left.equalTo(channelNameLabel.snp.right).inset(-10)
			make.width.equalTo(60)
		}
		
		self.separatorInset.left = 90
		self.selectionStyle = .none
		
		trackImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		trackNameLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		channelNameLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		timeLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		
		trackNameLabel.layer.masksToBounds = true
		channelNameLabel.layer.masksToBounds = true
		timeLabel.layer.masksToBounds = true
		
		trackNameLabel.layer.cornerRadius = 4
		channelNameLabel.layer.cornerRadius = 4
		timeLabel.layer.cornerRadius = 4

		trackNameLabel.text = " "
		channelNameLabel.text = " "
		timeLabel.text = " "

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
