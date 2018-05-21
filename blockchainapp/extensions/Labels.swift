//
//  Labels.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 21.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class SmallLabel: UILabel {
    init() {
        super.init(frame: CGRect.zero)
        self.font = AppFont.Button.mid
        self.textColor = AppColor.Title.lightGray
    }
    
    convenience init(title: String) {
        self.init()
        self.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
