import UIKit

struct AppColor {
	struct Title {
		static let light = UIColor.white
		static let dark = UIColor.black
		static let gray = UIColor.init(white: 74.0/255, alpha: 1)
		static let lightGray = UIColor.init(white: 155.0/255, alpha: 1)
	}
	
	struct Element {
		static let tomato = UIColor.init(redInt: 243, greenInt: 71, blueInt: 36, alpha: 1)
		static let subscribe = UIColor.red
		static let redBlur = UIColor.init(redInt: 255, greenInt: 102, blueInt: 102, alpha: 0.6)
		static let tagColor = UIColor.init(redInt: 31, greenInt: 60, blueInt: 74, alpha: 1)
	}
}

struct AppFont {
	struct Title {
		static let big = UIFont.systemFont(ofSize: 24, weight: .regular)
		static let mid = UIFont.systemFont(ofSize: 18, weight: .medium)
		static let midBold = UIFont.systemFont(ofSize: 18, weight: .bold)
		static let sml = UIFont.systemFont(ofSize: 14, weight: .bold)
		static let info = UIFont.systemFont(ofSize: 12, weight: .medium)
	}
	struct Button {
		static let mid = UIFont.systemFont(ofSize: 16, weight: .medium)
	}
	struct Text {
		static let mid = UIFont.systemFont(ofSize: 14, weight: .regular)
		static let descr = UIFont.systemFont(ofSize: 14, weight: .medium)
	}
	
}

extension UIColor {
    convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat) {
        self.init(red: CGFloat(redInt) / 255,
                green: CGFloat(greenInt) / 255,
                blue: CGFloat(blueInt) / 255,
                alpha: alpha)
    }
	
	func img(size: CGSize = CGSize.init(width: 1, height: 1)) -> UIImage {
		let rect = CGRect.init(origin: CGPoint.zero, size: size)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		context!.setFillColor(self.cgColor)
		context!.fill(rect)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return img!
	}
	
	static func gradImg(colors: [UIColor], vector: CGPoint = CGPoint.init(x: 0, y: 1)) -> UIImage? {
		let layer = CAGradientLayer.init()
		layer.colors = colors
		layer.startPoint = CGPoint.zero
		layer.endPoint = vector
		
		UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 20, height: 20), false, 0)
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		layer.render(in: context)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return img
	}
	
	func circle(diameter: CGFloat) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
		guard let ctx = UIGraphicsGetCurrentContext() else {
			return nil
		}
		ctx.saveGState()
		
		let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		ctx.setFillColor(self.cgColor)
		ctx.fillEllipse(in: rect)
		
		ctx.restoreGState()
		let img = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return img
	}
}
