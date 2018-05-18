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
	
	func url() -> URL? {
        if let url = URL(string: self) {
            return url
        }
        
		if String(self.prefix(4)) == "http", let str = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
			return URL(string: str)
		}
		
		var result = "https://manage.letitplay.io/"
		if !self.contains("uploads") {
			result += "uploads/"
		}
		if let path = (result + self).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
			return URL(string: path)
		}
		return nil
	}
	
    func buildImageURL() -> URL? {
		
		if String(self.prefix(4)) == "http", let _ = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return URL(string: self)
		}
		
        var result = "https://manage.letitplay.io/"
        if !self.contains("uploads") {
            result += "uploads/"
        }
		if let path = (result + self).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
			return URL(string: path)
		}
        return nil
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

extension Date {
	func formatString() -> String {
		let dateRangeEnd = Date()
		let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: self, to: dateRangeEnd)
		
		if let day = components.day, day != 0 {
			if day > 7 {
                if Locale.preferredLanguages[0] == "fr" {
                    return LocalizedStrings.TimeAgo.ago + "\(Int(Double(day)/7))" + LocalizedStrings.TimeAgo.week
                }
				return "\(Int(Double(day)/7))" + LocalizedStrings.TimeAgo.weekAgo
			}
            if Locale.preferredLanguages[0] == "fr" {
                return LocalizedStrings.TimeAgo.ago + "\(day)" + LocalizedStrings.TimeAgo.day
            }
			return "\(day)" + LocalizedStrings.TimeAgo.dayAgo
		} else
			if let hours = components.hour, hours != 0 {
                if Locale.preferredLanguages[0] == "fr" {
                    return LocalizedStrings.TimeAgo.ago + "\(hours)" + LocalizedStrings.TimeAgo.hour
                }
				return "\(hours)" + LocalizedStrings.TimeAgo.hourAgo
			} else
				if let min = components.minute, min != 0 {
                    if Locale.preferredLanguages[0] == "fr" {
                        return LocalizedStrings.TimeAgo.ago + "\(min)" + LocalizedStrings.TimeAgo.minute
                    }
					return "\(min)" + LocalizedStrings.TimeAgo.minuteAgo
				} else
					if let sec = components.second {
                        if Locale.preferredLanguages[0] == "fr" {
                            return LocalizedStrings.TimeAgo.ago + "\(sec)" + LocalizedStrings.TimeAgo.second
                        }
						return "\(sec)" + LocalizedStrings.TimeAgo.secondAgo
		}
		return "1" + LocalizedStrings.TimeAgo.secondAgo
	}
}

extension URL {
	init?(string: String?) {
		if let str = string {
			self.init(string: str)
			return
		}
		return nil
	}
}
