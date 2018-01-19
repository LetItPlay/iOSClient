//
//  ProfileViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 22/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

class ProfileViewController: UIViewController {

	let tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
	let profileView = ProfileTopView()
	
	var tracks: [Track] = []
	var currentIndex: Int = -1
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		tableView.tableHeaderView = profileView
		tableView.contentInset.bottom = 72
		
		self.tableView.separatorColor = self.tableView.backgroundColor
		
		self.tableView.separatorStyle = .none
		
		self.tableView.reloadData()
        // Do any additional setup after loading the view.
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		
		self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.tableView.separatorColor = UIColor.init(red: 243.0/255, green: 71.0/255, blue: 36.0/255, alpha: 0.2)
		
		let view = UIView()
		self.view.addSubview(view)
		view.backgroundColor = UIColor.white
		view.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(20)
		}
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPlayed(notification:)),
											   name: AudioController.AudioStateNotification.playing.notification(),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(trackPaused(notification:)),
											   name: AudioController.AudioStateNotification.paused.notification(),
											   object: nil)

		
		self.profileView.logoutButton.addTarget(self, action: #selector(langChanged(_:)), for: .touchUpInside)
		self.profileView.logoutButton.isSelected = UserSettings.language == .en
	}
	
	@objc func langChanged(_: UIButton) {
		if self.profileView.logoutButton.isSelected {
			UserSettings.language = .ru
		} else {
			UserSettings.language = .en
		}
		self.profileView.logoutButton.isSelected = !self.profileView.logoutButton.isSelected
		NotificationCenter.default.post(name: SettingsNotfification.changed.notification() , object: nil, userInfo: nil)
		self.currentIndex = -1
		self.reloadData()
		
		AudioController.main.make(command: .pause)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func settingsChanged(notification: Notification) {
		self.reloadData()
	}
	
	
	@objc func trackPlayed(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int, let index = self.tracks.index(where: {$0.id == id}) {
			self.currentIndex = index
			self.tableView.reloadData()
		}
	}
	
	@objc func trackPaused(notification: Notification) {
		if let id = notification.userInfo?["ItemID"] as? Int, let _ = self.tracks.index(where: {$0.id == id}) {
			self.currentIndex = -1
			self.tableView.reloadData()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.reloadData()
	}
	
	func reloadData() {
		let realm = try? Realm()
		let likeMan = LikeManager.shared
		self.tracks = realm?.objects(Track.self).map({$0}).filter({likeMan.hasObject(id: $0.id) && $0.lang == UserSettings.language.rawValue}) ?? []
		self.tableView.reloadData()
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
		return self.tracks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID) as! SmallTrackTableViewCell
		
		let track = self.tracks[indexPath.item]
		cell.track = track
		cell.dataLabels[.listens]?.isHidden = self.currentIndex == indexPath.item
		cell.dataLabels[.playingIndicator]?.isHidden = self.currentIndex != indexPath.item
		cell.timeLabel.isHidden = true
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contr = AudioController.main
		contr.loadPlaylist(playlist: ("Liked".localized, self.tracks.map({$0.audioTrack()})), playId: self.tracks[indexPath.item].audiotrackId())
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .white
		
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.text = "Tracks you’ve liked".localized
		
		let tracks = IconedLabel.init(type: .tracks)
		tracks.setData(data: Int64(self.tracks.count))
		
		let time = IconedLabel.init(type: .time)
		time.setData(data: Int64(self.tracks.map({$0.audiofile?.lengthSeconds ?? 0}).reduce(0, {$0 + $1})))
		
		view.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(12)
			make.left.equalToSuperview().inset(16)
		}
		
		view.addSubview(tracks)
		tracks.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(label.snp.bottom).inset(-7)
		}
		
		view.addSubview(time)
		time.snp.makeConstraints { (make) in
			make.left.equalTo(tracks.snp.right).inset(-8)
			make.centerY.equalTo(tracks)
		}
		
		let line = UIView()
		line.backgroundColor = AppColor.Element.redBlur
		line.layer.cornerRadius = 1
		line.layer.masksToBounds = true
		
		view.addSubview(line)
		line.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.bottom.equalToSuperview()
			make.height.equalTo(2)
		}
		
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 81
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.tracks[indexPath.item]
		return SmallTrackTableViewCell.height(text: track.name, width: tableView.frame.width)
	}}

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
		profileImageView.layer.masksToBounds = true
		profileImageView.layer.shadowColor = UIColor.black.cgColor
		profileImageView.layer.shadowOffset = CGSize.zero
		profileImageView.layer.shadowRadius = 10.0
		profileImageView.layer.shadowOpacity = 0.1
		profileImageView.layer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: -10, y: -10), size: CGSize.init(width: 260, height: 260)), cornerRadius: 130).cgPath
		profileImageView.layer.shouldRasterize = true
		profileImageView.contentMode = .scaleAspectFill
		
		profileImageView.image = UIImage(named: "placeholder")
		bluredimageView.image = UIImage(named: "placeholder")
		
//		blur.contentView.addSubview(self.changePhotoButton)
//		self.changePhotoButton.snp.makeConstraints { (make) in
//			make.right.equalTo(profileImageView)
//			make.bottom.equalTo(profileImageView).inset(30)
//			make.width.equalTo(40)
//			make.height.equalTo(40)
//		}
//
//		changePhotoButton.layer.cornerRadius = 20

		blur.contentView.addSubview(profileNameLabel)
		profileNameLabel.snp.makeConstraints { (make) in
//			make.centerX.equalTo(profileImageView)
			make.top.equalTo(profileImageView.snp.bottom).inset(-52)
			make.right.equalTo(profileImageView.snp.right)
			make.left.equalTo(profileImageView.snp.left)
		}
		
		profileNameLabel.text = "Your future profile".localized
		profileNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		profileNameLabel.textAlignment = .center
		profileNameLabel.isUserInteractionEnabled = false

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
			make.top.equalTo(highlight.snp.bottom).inset(-24)
			make.centerX.equalToSuperview()
		}
		
		logoutButton.setBackgroundImage(UIColor.init(white: 2.0/255, alpha: 0.1).img(), for: .normal)
		logoutButton.layer.cornerRadius = 6
		logoutButton.layer.masksToBounds = true
		logoutButton.setTitle("Switch to English 🇬🇧", for: .normal)
		logoutButton.setTitle("Поменять на Русский 🇷🇺", for: .selected)
		logoutButton.titleLabel?.font = AppFont.Button.mid
		logoutButton.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
		logoutButton.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 17, bottom: 6, right: 17)
		logoutButton.semanticContentAttribute = .forceRightToLeft
		
		let bot = CALayer()
		bot.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 510), size: CGSize.init(width: 414, height: 1))
		bot.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1).cgColor
		blur.contentView.layer.addSublayer(bot)
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
