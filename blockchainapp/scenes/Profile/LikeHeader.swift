//
//  LikeHeader.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 01.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class LikeHeader: UIView {
    
    let tracks = IconedLabel.init(type: .tracks)
    let time = IconedLabel.init(type: .time)
    
    init() {
        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 81)))
        
        self.commonInit()
    }
    
    func commonInit()
    {
        self.backgroundColor = .white
        
        let label = UILabel()
        label.font = AppFont.Title.big
        label.textColor = AppColor.Title.dark
        label.text = "Tracks you’ve liked".localized
        
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(12)
            make.left.equalToSuperview().inset(16)
        }
        
        self.addSubview(tracks)
        tracks.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(label.snp.bottom).inset(-7)
        }
        
        self.addSubview(time)
        time.snp.makeConstraints { (make) in
            make.left.equalTo(tracks.snp.right).inset(-8)
            make.centerY.equalTo(tracks)
        }
        
        let line = UIView()
        line.backgroundColor = AppColor.Element.redBlur
        line.layer.cornerRadius = 1
        line.layer.masksToBounds = true
        
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    func fill(count: String, length: String) {
        tracks.set(text: count)
        time.set(text: length)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
