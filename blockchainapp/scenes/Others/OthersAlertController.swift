//
//  OthersViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 09.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class OthersAlertController: UIAlertController {
    
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
        
        self.view.tintColor = AppColor.Element.redBlur.withAlphaComponent(0.8)
        
        self.addAction(UIAlertAction(title: "Поделиться", style: .default, handler: { (action) in
            self.emitter.send(event: OthersEvent.shareTrack(viewController: self.viewController))
        }))
        
        self.addAction(UIAlertAction(title: "Пожаловаться", style: .default, handler: { (action) in
            let alert = UIAlertController(title: "Пожаловаться на", message: "", preferredStyle: .alert)
            
            for report in self.viewModel.reportObjects {
                alert.addAction(UIAlertAction(title: report.title, style: .default, handler: { (_) in
                    self.emitter.send(event: report.event)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            
            self.viewController.present(alert, animated: true)
        }))
        
        self.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension OthersAlertController: OthersVMDelegate {
}
