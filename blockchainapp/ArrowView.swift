import UIKit

class ArrowView: UIView {
    
    private var isFlat: Bool = false
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
        
//        self.backgroundColor = .gray
        right.backgroundColor = UIColor.gray.cgColor
        left.backgroundColor = UIColor.gray.cgColor
        
        self.setFlat(self.isFlat, animated: false)
    }
    
    func setFlat(_ isFlat: Bool, animated: Bool = true) {
        let size = self.frame.size
        print(size)
        let ratio = CGFloat.pi/2 - atan((size.width / 2) / size.height)
        let width = isFlat ? size.width / 2 : CGFloat( round( sqrt( size.width * size.width / 4 + size.height * size.height ) ) )
        right.frame = CGRect.init(origin: CGPoint.init(x: 0, y: size.height), size: CGSize.init(width: width + 3, height: 5))
        left.frame = CGRect.init(origin: CGPoint.init(x: size.width/2 - 3, y: size.height), size: CGSize.init(width: width + 3, height: 5))
        if !isFlat {
            right.setAffineTransform(CGAffineTransform.identity.translatedBy(x: -2.5, y: -size.height/2 - 2).rotated(by: ratio))
            left.setAffineTransform(CGAffineTransform.identity.translatedBy(x: -1.5, y: -size.height/2 - 2).rotated(by: -ratio))
        } else {
            right.setAffineTransform(CGAffineTransform.identity.translatedBy(x: 0, y: -2))
            left.setAffineTransform(CGAffineTransform.identity.translatedBy(x: 0, y: -2))
        }
        print(right.frame)
        print(left.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
