//
//  StyleExtension.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

extension UIColor {
    @nonobjc class var vaBlack: UIColor {
        return UIColor(white: 3.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var vaTomato: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 71.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var vaWhite: UIColor {
        return UIColor(white: 250.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var vaCharcoalGrey: UIColor {
        return UIColor(white: 74.0 / 255.0, alpha: 1.0)
    }
}

// Sample text styles

extension UIFont {
    class func vaHeaderFont() -> UIFont {
        return UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightRegular)
    }
}

// string

extension String {
    func buildImageURL() -> URL? {
        return URL(string: "http://176.31.100.18:8182/" + self)
    }
}
