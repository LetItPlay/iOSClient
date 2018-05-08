//
//  MainChannelsCategotyCollectionViewCell.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 04.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class MainChannelsCategotyCollectionViewCell: UICollectionViewCell {
    
    public static let cellIdentifier = "CategoryChannel"
    
    var imageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "channelPreviewImg")
        return imageView
    }()
    
    let channelLabel: UILabel = {
        let channelLabel = UILabel()
        channelLabel.textColor = .black
        channelLabel.font = AppFont.Text.mid
        channelLabel.frame.size = CGSize(width: 130, height: 36)
        channelLabel.numberOfLines = 2
        channelLabel.lineBreakMode = .byWordWrapping
        return channelLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.viewInitialize()
    }
    
    func fill(channel: CategoryChannelViewModel) {
        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: channel.imageURL, placeholderImage: UIImage(named: "channelPreviewImg"), options: SDWebImageOptions.refreshCached, completed: nil)
            
            self.channelLabel.text = channel.name
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewInitialize() {
        self.contentView.frame = CGRect(x: 0, y: 0, width: 130, height: 170)
        
        contentView.addSubview(imageView)
        contentView.addSubview(channelLabel)
        channelLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).inset(4)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
