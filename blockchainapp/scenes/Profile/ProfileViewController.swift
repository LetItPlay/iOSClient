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

class ProfileViewController: UIViewController, LikesVMDelegate {

    var emitter: LikesEmitterProtocol?
    var viewModel: LikesViewModel!

	let tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    var profileView: ProfileTopView!
    let imagePicker: UIImagePickerController = {
        var imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        return imagePicker
    }()
	
	var tracks: [TrackViewModel] = []
	var currentIndex: Int = -1
    var isKeyboardShown = true
	
	let header: LikeHeader = LikeHeader()
	
    convenience init(view: ProfileTopView, emitter: LikesEmitterProtocol, viewModel: LikesViewModel) {
		self.init(nibName: nil, bundle: nil)
        self.profileView = view
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
	}
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        
        self.profileView.addGestureRecognizer(tap)
        
        imagePicker.delegate = self
        profileView.delegate = self
		tableView.tableHeaderView = profileView
		tableView.contentInset.bottom = 50
		
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
		
		self.profileView.languageButton.addTarget(self, action: #selector(langChanged(_:)), for: .touchUpInside)
	}
    
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShown = true
        AnalyticsEngine.sendEvent(event: .profileEvent(on: .name))
        tableView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    @objc func dismissKeyboard(_ sender: Any) {
        isKeyboardShown = false
        view.endEditing(true)
        let height = sender is UITapGestureRecognizer ? 0 : 100
        tableView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
        let name = self.profileView.profileNameLabel.text!
        self.profileView.emitter?.send(event: ProfileEvent.setName(name))
    }
	
	@objc func langChanged(_: UIButton) {
        self.profileView.emitter?.send(event: ProfileEvent.setLanguage)
        
		NotificationCenter.default.post(name: SettingsNotfification.changed.notification() , object: nil, userInfo: nil)
		NotificationCenter.default.post(name: InAppUpdateNotification.setting.notification(), object: nil)
		self.currentIndex = -1
		
		AudioController.main.make(command: .pause)
	}
	
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
    
        self.emitter?.send(event: LifeCycleEvent.appear)
        self.profileView.emitter?.send(event: LifeCycleEvent.appear)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.emitter?.send(event: LifeCycleEvent.disappear)
        self.profileView.emitter?.send(event: LifeCycleEvent.disappear)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        self.tracks = viewModel.tracks
        self.tableView.reloadData()
    }
    
    func make(updates: [CollectionUpdate : [Int]]) {
        tableView.beginUpdates()
        for key in updates.keys {
            if let indexes = updates[key]?.map({IndexPath(row: $0, section: 0)}) {
                switch key {
                case .insert:
                    tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                case .delete:
                    tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                case .update:
                    tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                }
            }
        }
        tableView.endUpdates()
    }
}

extension ProfileViewController: ProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func setName() {
        self.dismissKeyboard(UITapGestureRecognizer.init())
    }
    
    func addImage() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: {
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let image = UIImagePNGRepresentation(pickedImage)!
            self.profileView.emitter?.send(event: ProfileEvent.setImage(image))
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isKeyboardShown {
            self.dismissKeyboard(scrollView)
        }
    }
    
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
		cell.dataLabels[.listens]?.isHidden = self.tracks[indexPath.row].isPlaying
		cell.dataLabels[.playingIndicator]?.isHidden = !self.tracks[indexPath.row].isPlaying
		cell.timeLabel.isHidden = true
		cell.separator.isHidden = indexPath.item + 1 == self.tracks.count
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsEngine.sendEvent(event: .profileEvent(on: .like))
        self.emitter?.make(action: .selected, index: indexPath.row)
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        header.fill(count: Int64(self.tracks.count).formatAmount(), length: self.viewModel.length)
		return header
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
	}
}

protocol ProfileViewDelegate {
    func addImage()
    func setName()
}

class LikeHeader: UIView {
	
	let tracks = IconedLabel.init(type: .tracks)
	let time = IconedLabel.init(type: .time)
	
	init() {
		super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 81)))
		
		self.backgroundColor = .white
		
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.text = "Tracks you’ve liked".localized
        
		self.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(12)
			make.left.equalToSuperview().inset(16)
		}
		
		self.addSubview(tracks)
		tracks.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(label.snp.bottom).inset(-7)
		}
		
		self.addSubview(time)
		time.snp.makeConstraints { (make) in
			make.left.equalTo(tracks.snp.right).inset(-8)
			make.centerY.equalTo(tracks)
		}
		
		let line = UIView()
		line.backgroundColor = AppColor.Element.redBlur
		line.layer.cornerRadius = 1
		line.layer.masksToBounds = true
		
		self.addSubview(line)
		line.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.bottom.equalToSuperview()
			make.height.equalTo(2)
		}
	}
	
	func fill(count: String, length: String) {
		tracks.set(text: count)
		time.set(text: length)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


class ProfileTopView: UIView, ProfileVMDelegate {
    
    func make(updates: [ProfileUpdate]) {
        for data in updates {
            switch data {
            case .image:
                let image = UIImage.init(data: self.viewModel.imageData!)
                profileImageView.image = image
                bluredImageView.image = image
            case .language:
                self.languageButton.setTitle(self.viewModel.languageString, for: .normal)
            case .name:
                self.setName(name: self.viewModel.name)
            }
        }
    }
    
    func setName(name: String)
    {
        if name != "name"
        {
            profileNameLabel.text = name
        }
        else
        {
            profileNameLabel.placeholder = "name"
        }
    }
	
    var delegate: ProfileViewDelegate?
    
    var emitter: ProfileEmitterProtocol?
    var viewModel: ProfileViewModel!
    
	let profileImageView: UIImageView = UIImageView()
	let bluredImageView: UIImageView = UIImageView()
	let profileNameLabel: UITextField = UITextField()
	let changePhotoButton: UIButton = UIButton()
	let languageButton: UIButton = UIButton()
	
    init(emitter: ProfileEmitterProtocol, viewModel: ProfileViewModel) {
		super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 511)))

        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
		bluredImageView.layer.cornerRadius = 140
		bluredImageView.layer.masksToBounds = true
		
		self.addSubview(bluredImageView)
		bluredImageView.snp.makeConstraints { (make) in
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
		
        blur.contentView.addSubview(self.changePhotoButton)
        self.changePhotoButton.snp.makeConstraints { (make) in
            make.right.equalTo(profileImageView)
            make.bottom.equalTo(profileImageView).inset(30)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        changePhotoButton.layer.cornerRadius = 20
        changePhotoButton.setImage(UIImage.init(named: "editPhotoInactive"), for: .normal)
        changePhotoButton.backgroundColor = .red
        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped(_:)), for: .touchUpInside)

		blur.contentView.addSubview(profileNameLabel)
		profileNameLabel.snp.makeConstraints { (make) in
//			make.centerX.equalTo(profileImageView)
			make.top.equalTo(profileImageView.snp.bottom).inset(-52)
			make.right.equalTo(profileImageView.snp.right)
			make.left.equalTo(profileImageView.snp.left)
		}
		
		profileNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		profileNameLabel.textAlignment = .center
        profileNameLabel.returnKeyType = .done

		let highlight = UIView()
		highlight.backgroundColor = UIColor.red.withAlphaComponent(0.2)
		blur.contentView.addSubview(highlight)
		highlight.snp.makeConstraints { (make) in
			make.bottom.equalTo(profileNameLabel).inset(-1)
			make.left.equalTo(profileNameLabel).inset(-14)
			make.right.equalTo(profileNameLabel).inset(-14)
			make.height.equalTo(14)
		}

		blur.contentView.addSubview(languageButton)
		languageButton.snp.makeConstraints { (make) in
			make.top.equalTo(highlight.snp.bottom).inset(-24)
			make.centerX.equalToSuperview()
		}
		
		languageButton.setBackgroundImage(UIColor.init(white: 2.0/255, alpha: 0.1).img(), for: .normal)
		languageButton.layer.cornerRadius = 6
		languageButton.layer.masksToBounds = true
		languageButton.titleLabel?.font = AppFont.Button.mid
		languageButton.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
		languageButton.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 17, bottom: 6, right: 17)
		languageButton.semanticContentAttribute = .forceRightToLeft
		
		let bot = CALayer()
		bot.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 510), size: CGSize.init(width: 414, height: 1))
		bot.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1).cgColor
		blur.contentView.layer.addSublayer(bot)

        emitter.send(event: LifeCycleEvent.initialize)
	}
    
    @objc func changePhotoButtonTapped(_ sender: Any) {
        AnalyticsEngine.sendEvent(event: .profileEvent(on: .avatar))
        delegate?.addImage()
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
