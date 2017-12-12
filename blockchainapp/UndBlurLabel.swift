//
//  UndBlurLabel.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 21/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class UndBlurLabel: UIView {
	
//	let blurView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.regular))
	let label: UILabel = UILabel.init(frame: CGRect.zero)
	let shapeLayer: CAShapeLayer = CAShapeLayer()
	
	init() {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = AppColor.Element.redBlur.withAlphaComponent(0.9)
		
//		self.addSubview(blurView)
//		blurView.snp.makeConstraints { (make) in
//			make.edges.equalToSuperview()
//		}
		
		self.addSubview(label)
		label.numberOfLines = 3
		self.label.snp.makeConstraints { (make) in
			make.edges.equalToSuperview().inset(4)
		}
//		self.layer.mask = shapeLayer
	}
	
//	override func layoutSubviews() {
//		super.layoutSubviews()
////		if let title = label.text, title != "" {
////			self.updateShape(text: title)
////		} else {
////			self.updateShape(text: "  ")
////		}
//	}
	
	func setTitle(title: String) {
		self.label.attributedText = formatString(text: title)
//		self.layoutSubviews()
	}
	
	func updateShape(text: String) {
		let widths = self.calcLinesWidths(text: formatString(text: text, calc: true), frame: self.label.frame).map({$0 + 4 + 4 + 4})
		if widths.count > 0 {
			let tooBig = widths.count > 3
			let path = UIBezierPath.init()
			path.move(to: CGPoint.zero)
			path.addLine(to: CGPoint.init(x: min(widths[0], self.frame.width), y: 0))
			path.addLine(to: CGPoint.init(x: min(widths[0], self.frame.width), y: 4))
			for i in 1..<widths.prefix(3).count {
				path.addLine(to: CGPoint.init(x: min(widths[i - 1], self.frame.width) , y: CGFloat(i*29) + 4))
				path.addLine(to: CGPoint.init(x: min(widths[i], self.frame.width), y: CGFloat(i*29) + 4))
			}
			if tooBig {
				path.addLine(to: CGPoint.init(x: self.frame.width, y: path.currentPoint.y))
				path.addLine(to: CGPoint.init(x: self.frame.width, y: self.frame.height))
			} else {
				path.addLine(to: CGPoint.init(x: min(widths.last ?? 500.0, self.frame.width), y: self.frame.height))
			}
			path.addLine(to: CGPoint.init(x: 0, y: self.frame.height))
			path.close()
			
			self.shapeLayer.path = path.cgPath
		} else {
			self.shapeLayer.path = UIBezierPath.init(rect: CGRect.init(origin: CGPoint.zero, size: self.frame.size)).cgPath
		}
	}
	
	
	func formatString(text: String, calc: Bool = false) -> NSAttributedString {
		let para = NSMutableParagraphStyle()
		para.alignment = .left
		para.minimumLineHeight = 29
		para.maximumLineHeight = 29
		para.lineBreakMode = calc ? .byWordWrapping : .byTruncatingTail
		return NSAttributedString.init(string: text,
									   attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular),
													.foregroundColor: UIColor.white,
													.paragraphStyle: para])
		// .kern:
	}
	
	func calcLinesWidths(text: NSAttributedString, frame: CGRect) -> [CGFloat] {
		var newFrame = frame
		newFrame.size.height = 200
		var result: [CGFloat] = []
		let fs = CTFramesetterCreateWithAttributedString(text)
		let frame = CTFramesetterCreateFrame(fs, CFRangeMake(0, 0), CGPath.init(rect: newFrame, transform: nil), nil)
		let lines = CTFrameGetLines(frame)
		for line in lines as! Array<CTLine> {
			let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
			let range = CTLineGetStringRange(line)
			print("range = \(range.location) \(range.length)")
			result.append(bounds.width - bounds.origin.x)
		}
		return result
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}
