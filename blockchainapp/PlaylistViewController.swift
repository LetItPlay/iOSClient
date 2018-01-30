//
//  PlaylistViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class PlaylistViewController: UIViewController {

	let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .gray
		
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(60)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
        // Do any additional setup after loading the view.
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
