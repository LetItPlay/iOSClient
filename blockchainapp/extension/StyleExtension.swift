//
//  StyleExtension.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import TagListView

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
    
    @nonobjc class var vaRed: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    @nonobjc class var vaActive: UIColor {
        return vaRed
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
        var result = "https://manage.letitplay.io/"
        if !self.contains("uploads") {
            result += "uploads/"
        }
        return URL(string: result + self)
    }
}

extension Int64 {
	func formatTime() -> String {
		let hours = self / 60 / 60
		let min = self / 60 % 60
		let sec = self % 60
		var res = "\(min):\(sec)"
		if hours != 0 {
			res = "\(hours):" + res
		}
		return res
//		return String(format:"%02i:%02i", Int(maxTime) / 60 % 60, Int(maxTime) % 60)
	}
}

// UIImage

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
