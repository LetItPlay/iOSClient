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
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = AppColor.Element.redBlur.withAlphaComponent(0.8)
        
        self.addAction(UIAlertAction(title: LocalizedStrings.Others.share, style: .default, handler: { (action) in
            self.emitter.send(event: OthersEvent.shareTrack(viewController: self.viewController))
        }))
        
        self.addAction(UIAlertAction(title: self.viewModel.alertData.actionTitle, style: .default, handler: { (action) in
            let alert = UIAlertController(title: self.viewModel.alertData.alertTitle, message: self.viewModel.alertData.alertMessage, preferredStyle: .alert)
            
            if self.viewModel.alertData.showOkButton {
                alert.addAction(UIAlertAction(title: LocalizedStrings.SystemMessage.ok, style: .default, handler: { (_) in
                    self.emitter.send(event: OthersEvent.okButtonTouched)
                }))
            }
            
            for action in self.viewModel.alertData.alertAcrions {
                alert.addAction(UIAlertAction(title: action.title, style: .default, handler: { (_) in
                    self.emitter.send(event: action.event)
                }))
            }
            
            alert.addAction(UIAlertAction(title: LocalizedStrings.SystemMessage.cancel, style: .default, handler: nil))
            
            self.viewController.present(alert, animated: true)
        }))
        
        self.addAction(UIAlertAction(title: LocalizedStrings.SystemMessage.cancel, style: .cancel, handler: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension OthersAlertController: OthersVMDelegate {
}
