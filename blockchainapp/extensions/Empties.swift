//
//  Empties.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 11.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class EmptyLabel: UILabel {
    convenience init(title: String) {
        self.init()
        self.font = AppFont.Title.sectionNotBold
        self.textColor = AppColor.Element.emptyMessage
        self.textAlignment = .center
        self.numberOfLines = 0
        self.text = title
        self.isHidden = true
    }
}

class EmptyButton: UIButton {
    convenience init(title: String) {
        self.init()
        self.titleLabel?.font = AppFont.Title.section
        self.setTitle(title, for: .normal)
        self.setTitleColor(.red, for: .normal)
        self.titleLabel?.textAlignment = .center
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        self.contentEdgeInsets = UIEdgeInsetsMake(3, 12.5, 3, 12.5)
        self.isHidden = true
    }
}
