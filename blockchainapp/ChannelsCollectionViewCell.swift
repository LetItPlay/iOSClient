//
//  ChannelsCollectionViewCell.swift
//  blockchainapp
//
//  Created by Polina on 26.01.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelsCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(image: URL)
    {
//        if let urlString = image.buildImageURL() {
//            imageView.sd_setImage(with: urlString)
//        } else {
//            imageView.image = nil
//        }
        imageView.sd_setImage(with: image)
    }
}
