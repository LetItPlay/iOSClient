import UIKit

class ArrowView: UIView {
    
    private var isFlat: Bool = true
    private let right: CALayer = CALayer()
    private let left: CALayer = CALayer()
    
    init() {
        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 37, height: 12)))
        
        self.layer.addSublayer(right)
        self.layer.addSublayer(left)
        right.masksToBounds = true
        right.cornerRadius = 3
        left.masksToBounds = true
        left.cornerRadius = 3
        
        right.backgroundColor = UIColor.gray.cgColor
        left.backgroundColor = UIColor.gray.cgColor
		
		let size = self.frame.size
		let width = CGFloat( round( sqrt( size.width * size.width / 4 + size.height * size.height ) ) )
		right.frame = CGRect.init(origin: CGPoint.init(x: 0, y: size.height - 5), size: CGSize.init(width: width + 2, height: 5))
		left.frame = CGRect.init(origin: CGPoint.init(x: size.width/2 - 2, y: size.height - 5), size: CGSize.init(width: width + 2, height: 5))
		
        self.setFlat(false, animated: false)
    }
    
    func setFlat(_ isFlat: Bool, animated: Bool = true) {
		if isFlat != self.isFlat {
			self.isFlat = isFlat
			let size = self.frame.size
			let ratio = CGFloat.pi/2 - atan((size.width / 2) / size.height)
			if !isFlat {
				right.setAffineTransform(CGAffineTransform.identity.translatedBy(x: -2.5, y: -size.height/2 - 2).rotated(by: ratio))
				left.setAffineTransform(CGAffineTransform.identity.translatedBy(x: -1.5, y: -size.height/2 - 2).rotated(by: -ratio))
			} else {
				right.setAffineTransform(CGAffineTransform.identity)
				left.setAffineTransform(CGAffineTransform.identity)
			}
		}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
