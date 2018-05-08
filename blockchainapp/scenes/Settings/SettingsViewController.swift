//
//  SettingsViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 19/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import AssistantKit

enum SettingsNotfification: String {
	case changed = "Changed"
	
	func notification() -> Notification.Name {
		return Notification.Name.init(rawValue: "SettingsNotification" + self.rawValue)
	}
}

class SettingsViewController: UIViewController {
	
	func button() -> (UIButton, UILabel) {
		let button = UIButton()
		button.setTitle("English", for: .normal)
		button.setTitleColor(UIColor.red, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		button.contentHorizontalAlignment = .left
		button.contentEdgeInsets.left = 12
		
		button.layer.cornerRadius = 6
		button.layer.borderColor = UIColor.red.cgColor
		button.layer.borderWidth = 1.0
		button.layer.masksToBounds = true
		
		button.snp.makeConstraints { (make) in
			make.width.equalTo(162)
			make.height.equalTo(46)
		}
		
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
		label.isUserInteractionEnabled = false
		
		button.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(12)
			make.centerY.equalToSuperview()
		}
		
		return (button, label)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = UIColor.white
		
		let flags = ["🇬🇧","🇷🇺","🇫🇷"]
        
        let inset = self.view.frame.height / 47 * -1 //Device.screen == .inches_4_7 || Device.screen == .inches_4_0 ? -12 : -24
        let multiplicateur: CGFloat = Device.screen == .inches_4_7 || Device.screen == .inches_4_0 ? 2 : 3
		
		let title = UILabel()
		title.numberOfLines = 3
		let para = NSMutableParagraphStyle()
		para.minimumLineHeight = 41
		para.maximumLineHeight = 41
		para.alignment = .center
		title.attributedText = NSAttributedString.init(string:  "Select your language".localized, attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .bold),
																				.kern: 0.4,
																				.foregroundColor: UIColor.black,
																				.paragraphStyle: para])
		
		let lipIcon: UIImageView = UIImageView.init(image: UIImage.init(named: "redTriangle"))
		let lipText: UIImageView = UIImageView.init(image: UIImage.init(named: "textLogo"))
		
		let tupleEng = button()
		tupleEng.0.tag = 0
		tupleEng.0.setTitle("English", for: .normal)
		tupleEng.1.text = flags[0]
		
		let tupleRus = button()
		tupleRus.0.tag = 1
		tupleRus.0.setTitle("Русский", for: .normal)
		tupleRus.1.text = flags[1]
        
        let tupleFrance = button()
        tupleFrance.0.tag = 2
        tupleFrance.0.setTitle("Français", for: .normal)
        tupleFrance.1.text = flags[2]
		
		self.view.addSubview(lipText)
		lipText.snp.makeConstraints { (make) in
			make.bottom.equalTo(self.view.snp.centerY).inset(-88)
			make.centerX.equalToSuperview()
			make.size.equalTo(CGSize.init(width: 242, height: 36))
		}
		
		self.view.addSubview(lipIcon)
		lipIcon.snp.makeConstraints { (make) in
			make.bottom.equalTo(lipText.snp.top).inset(-30)
			make.centerX.equalToSuperview()
			make.size.equalTo(CGSize.init(width: 120, height: 120))
		}
        
        self.view.addSubview(tupleFrance.0)
        tupleFrance.0.snp.makeConstraints({ (make) in
            make.bottom.equalTo(inset * multiplicateur)
            make.centerX.equalToSuperview()
        })
		
		self.view.addSubview(tupleRus.0)
		tupleRus.0.snp.makeConstraints { (make) in
            make.bottom.equalTo(tupleFrance.0.snp.top).inset(inset)
			make.centerX.equalToSuperview()
		}
        
        self.view.addSubview(tupleEng.0)
        tupleEng.0.snp.makeConstraints { (make) in
            make.bottom.equalTo(tupleRus.0.snp.top).inset(inset)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.bottom.equalTo(tupleEng.0.snp.top).inset(inset * multiplicateur)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
		
		tupleEng.0.addTarget(self, action: #selector(langSelected(sender:)), for: .touchUpInside)
		tupleRus.0.addTarget(self, action: #selector(langSelected(sender:)), for: .touchUpInside)
        tupleFrance.0.addTarget(self, action: #selector(langSelected(sender:)), for: .touchUpInside)
    }
	
	@objc func langSelected(sender: UIButton) {
//        sender.isEnabled = false
//        
//        switch sender.tag {
//        case 0:
//            UserSettings.language = .en
//        case 1:
//            UserSettings.language = .ru
//        case 2:
//            UserSettings.language = .fr
//        default:
//            UserSettings.language = .none
//        }
//        
//        self.present(MainTabViewController(), animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
