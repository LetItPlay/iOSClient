//
//  ProfileViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 22/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {

	let tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		tableView.tableHeaderView = ProfileTopView()
		tableView.contentInset.bottom = 72
		
		self.tableView.reloadData()
        // Do any additional setup after loading the view.
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		
		self.tableView.register(LikedTrackTableViewCell.self, forCellReuseIdentifier: LikedTrackTableViewCell.cellID)
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.tableView.separatorColor = UIColor.init(red: 243.0/255, green: 71.0/255, blue: 36.0/255, alpha: 0.2)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
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

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LikedTrackTableViewCell.cellID)
		
		return cell ?? UITableViewCell.init()
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.init(white: 248.0/255, alpha: 1)
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
		label.text = "Tracks you've liked"
		view.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().inset(6)
		}
		let bot = CALayer()
		bot.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 59), size: CGSize.init(width: 414, height: 1))
		bot.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1).cgColor
		view.layer.addSublayer(bot)
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return LikedTrackTableViewCell.cellHeight
	}
}

class ProfileTopView: UIView {
	
	let profileImageView: UIImageView = UIImageView()
	let bluredimageView: UIImageView = UIImageView()
	let profileNameLabel: UITextField = UITextField()
	let changePhotoButton: UIButton = UIButton()
	let logoutButton: UIButton = UIButton()
	
	init() {
		super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 511)))
		
		bluredimageView.layer.cornerRadius = 140
		bluredimageView.layer.masksToBounds = true
		
		self.addSubview(bluredimageView)
		bluredimageView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().inset(68)
			make.width.equalTo(260)
			make.height.equalTo(260)
		}
		
		let blur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .regular))
		self.addSubview(blur)
		blur.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		blur.contentView.addSubview(profileImageView)
		profileImageView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().inset(78)
			make.width.equalTo(240)
			make.height.equalTo(240)
		}
		
		profileImageView.layer.cornerRadius = 120
		
		profileImageView.layer.shadowColor = UIColor.black.cgColor
		profileImageView.layer.shadowOffset = CGSize.zero
		profileImageView.layer.shadowRadius = 10.0
		profileImageView.layer.shadowOpacity = 0.1
		profileImageView.layer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: -10, y: -10), size: CGSize.init(width: 260, height: 260)), cornerRadius: 130).cgPath
		profileImageView.layer.shouldRasterize = true
		
		blur.contentView.addSubview(self.changePhotoButton)
		self.changePhotoButton.snp.makeConstraints { (make) in
			make.right.equalTo(profileImageView)
			make.bottom.equalTo(profileImageView).inset(30)
			make.width.equalTo(40)
			make.height.equalTo(40)
		}
		
		changePhotoButton.layer.cornerRadius = 20

		blur.contentView.addSubview(profileNameLabel)
		profileNameLabel.snp.makeConstraints { (make) in
//			make.centerX.equalTo(profileImageView)
			make.top.equalTo(profileImageView.snp.bottom).inset(-52)
			make.right.equalTo(profileImageView.snp.right)
			make.left.equalTo(profileImageView.snp.left)
		}
		
		profileNameLabel.text = "Anna Shekhtman"
		profileNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		profileNameLabel.textAlignment = .center

		let highlight = UIView()
		highlight.backgroundColor = UIColor.red.withAlphaComponent(0.2)
		blur.contentView.addSubview(highlight)
		highlight.snp.makeConstraints { (make) in
			make.bottom.equalTo(profileNameLabel).inset(-1)
			make.left.equalTo(profileNameLabel).inset(-14)
			make.right.equalTo(profileNameLabel).inset(-14)
			make.height.equalTo(14)
		}

		blur.contentView.addSubview(logoutButton)
		logoutButton.snp.makeConstraints { (make) in
			make.width.equalTo(240)
			make.height.equalTo(32)
			make.top.equalTo(highlight.snp.bottom).inset(-24)
			make.centerX.equalToSuperview()
		}
		
		let bot = CALayer()
		bot.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 510), size: CGSize.init(width: 414, height: 1))
		bot.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1).cgColor
		blur.contentView.layer.addSublayer(bot)
		
		profileImageView.backgroundColor = .red
		bluredimageView.backgroundColor = .green
//		profileNameLabel.backgroundColor = .blue
		changePhotoButton.backgroundColor = .black
		logoutButton.backgroundColor = .red
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
