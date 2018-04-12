//
//  OthersViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class OthersViewController: UIAlertController {
    
    var viewModel: OthersVMProtocol!
    var emitter: OthersEmitterProtocol!
    
    var viewController: UIViewController!
    
    var track: Any!
    
    init(viewModel: OthersVMProtocol, emitter: OthersEmitterProtocol, viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
        self.viewController = viewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = AppColor.Title.lightGray
        
//        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
//        let messageAttrString = NSMutableAttributedString(string: "", attributes: messageFont)
//        self.setValue(messageAttrString, forKey: "attributedTitle")
        
        self.addAction(UIAlertAction(title: "Поделиться", style: .default, handler: { (action) in
            self.emitter.send(event: OthersEvent.shareTrack(viewController: self.viewController))
        }))
        
        self.addAction(UIAlertAction(title: "Пожаловаться", style: .default, handler: { (action) in
            let alert = UIAlertController(title: "Пожаловаться на", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Спам", style: .default, handler: { _ in
                self.emitter.send(event: OthersEvent.report(.spam))
            }))
            
            alert.addAction(UIAlertAction(title: "Контент для взрослых", style: .default, handler: { _ in
                self.emitter.send(event: OthersEvent.report(.adultContent))
            }))
        
            alert.addAction(UIAlertAction(title: "Жестокий контент", style: .default, handler: { _ in
                self.emitter.send(event: OthersEvent.report(.cruelContent))
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            self.viewController.present(alert, animated: true)
        }))
        
//        self.addAction(UIAlertAction(title: "Скрыть", style: .default, handler: { (action) in
//            
//        }))
        
        self.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension OthersViewController: OthersVMDelegate {
    func addTrack() {
        
    }
}
