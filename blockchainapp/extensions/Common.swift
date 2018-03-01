//
//  Common.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 01.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class Common
{
    static func trackText(text: String) -> NSAttributedString {
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = .byWordWrapping
        para.minimumLineHeight = 22
        para.maximumLineHeight = 22
        return NSAttributedString.init(string: text, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .paragraphStyle: para])
    }
    
    static func height(text: String, width: CGFloat) -> CGFloat {
        let rect = self.trackText(text: text)
            .boundingRect(with: CGSize.init(width: width - 60 - 14 - 16 - 16, height: 9999),
                          options: .usesLineFragmentOrigin,
                          context: nil)
        return min(rect.height, 44) + 31 + 32
    }
}
