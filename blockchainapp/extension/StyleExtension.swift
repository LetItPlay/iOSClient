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
        return UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.regular)
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
		let res = hours == 0 ? "" : "\(hours):"
		let minString = hours == 0 ? "\(min)" : String.init(format: "%02i", min)
		let secString = String.init(format: "%02i", sec)
		return res + "\(minString):\(secString)"
//		return String(format:"%02i:%02i", Int(maxTime) / 60 % 60, Int(maxTime) % 60)
	}

    func formatAmount() -> String {
        var res: Float?
        var text = ""
        if self >= 1000 * 1000 {
            res = Float(self) / 1000000.0
            text = "KK"
        }
        if self >= 1000 {
            res = Float(self) / 1000.0
            text = "K"
        }
        if let res = res {
            return String.init(format: "%.01f" + text, res)
        }
        return "\(self)"
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
