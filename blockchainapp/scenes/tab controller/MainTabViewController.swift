//
//  MainTabViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 04/09/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let playerVC = AppManager.shared.audioPlayer {
            addChildViewController(playerVC)
            view.addSubview(playerVC.view)
            playerVC.didMove(toParentViewController: self)
            
            playerVC.view.translatesAutoresizingMaskIntoConstraints = false
            playerVC.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            playerVC.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            playerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -49).isActive = true
            playerVC.view.heightAnchor.constraint(equalToConstant: 72).isActive = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}