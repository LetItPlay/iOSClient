//
//  PlaylistTableViewCell.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 14/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class PlaylistTableViewCell: UITableViewCell {

	static let cellID = "PlaylistCellID"
	
	let playlistImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 6
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	let playlistTitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = AppColor.Title.dark
		label.font = AppFont.Title.mid
		label.numberOfLines = 2
		return label
	}()
	
	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = AppFont.Text.descr
		label.textColor = AppColor.Title.gray
		label.numberOfLines = 2
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(playlistImageView)
		playlistImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(10)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.height.equalTo(playlistImageView.snp.width).multipliedBy(3.0/4.0)
		}
		
		self.contentView.addSubview(playlistTitleLabel)
		playlistTitleLabel.snp.makeConstraints { (make) in
			make.top.equalTo(playlistImageView.snp.bottom).inset(-10)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
		
		self.contentView.addSubview(descriptionLabel)
		descriptionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(playlistTitleLabel.snp.bottom).inset(-4)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
	}
	
	static func titleString(string: String) -> NSAttributedString {
		return NSAttributedString(string: string, attributes: [.font: AppFont.Title.mid, .foregroundColor: AppColor.Title.dark])
	}
	
	static func descrString(string: String) -> NSAttributedString {
		return NSAttributedString(string: string, attributes: [.font: AppFont.Text.descr, .foregroundColor: AppColor.Title.gray])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	static func imageHeight(width: CGFloat) -> CGFloat {
		let ratio: CGFloat = 4.0/3.0
		return CGFloat(trunc(width/ratio))
	}

	static func height(title: String, desc: String, width: CGFloat) -> CGFloat {
		return 331.0
	}
}
