//
//  OthersViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class OthersViewController: UIAlertController {
    
    var track: Any!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = AppColor.Title.lightGray
        
        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
        let messageAttrString = NSMutableAttributedString(string: "", attributes: messageFont)
        self.setValue(messageAttrString, forKey: "attributedTitle")
        
        self.addAction(UIAlertAction(title: "Пожаловаться", style: .default, handler: { (action) in
            
        }))
        
        self.addAction(UIAlertAction(title: "Скрыть", style: .default, handler: { (action) in
            
        }))
        
        self.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func add(track: Any) {
        self.track = track
    }
    
    func add(controller: UIViewController) {
        self.addAction(UIAlertAction(title: "Поделиться", style: .default, handler: { (action) in
            MainRouter.shared.shareTrack(track: self.track, viewController: controller)
        }))
    }
}
