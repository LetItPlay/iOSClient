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

protocol ProfileViewDelegate {
    func addImage()
}

class ProfileViewController: UIViewController {

    var emitter: LikesEmitterProtocol?
    var viewModel: LikesViewModel!

	let tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    var profileView: ProfileHeaderView!
    let header: LikeHeader = LikeHeader()
    
    let imagePicker: UIImagePickerController = {
        var imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = .red
        return imagePicker
    }()
	
    var isKeyboardShown = true
	
    convenience init(view: ProfileHeaderView, emitter: LikesEmitterProtocol, viewModel: LikesViewModel) {
		self.init(nibName: nil, bundle: nil)
        self.profileView = view
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: false)
	}
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.viewInitialize()
	}
    
    func viewInitialize()
    {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.profileView.addGestureRecognizer(tap)
        
        imagePicker.delegate = self
        profileView.delegate = self
        
        self.tableView.tableHeaderView = profileView
        self.tableView.contentInset.bottom = 50
        
        self.tableView.separatorColor = UIColor.init(red: 243.0/255, green: 71.0/255, blue: 36.0/255, alpha: 0.2)
        self.tableView.separatorStyle = .none
        
        self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        if isKeyboardShown && self.profileView.profileNameTextField.isFirstResponder {
            isKeyboardShown = false
            view.endEditing(true)
            let height = sender is UITapGestureRecognizer ? 0 : 100
            tableView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
            let name = self.profileView.profileNameTextField.text!
            self.profileView.emitter?.send(event: ProfileEvent.setName(name))
        }
    }
	
	@objc func langChanged(_: UIButton) {
        var currentLanguage = ""
        switch UserSettings.language {
        case .ru:
            currentLanguage = "Русский"
        case .en:
            currentLanguage = "English"
        case .fr:
            currentLanguage = "Français"
        default:
            break
        }
        
        let languageAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        languageAlert.view.tintColor = AppColor.Title.lightGray
        
        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
        let messageAttrString = NSMutableAttributedString(string: "Select language".localized, attributes: messageFont)
        languageAlert.setValue(messageAttrString, forKey: "attributedTitle")
        
        for language in ["English", "Français", "Русский"] {
            if language == currentLanguage {
                languageAlert.addAction(UIAlertAction(title: language, style: .default, handler: { _ in
//                    self.profileView.emitter?.send(event: ProfileEvent.set(language: speed))
                }))
            }
            else {
                languageAlert.addAction(UIAlertAction(title: language, style: .destructive, handler: { _ in
                    self.profileView.emitter?.send(event: ProfileEvent.set(language: language))
                }))
            }
        }
        
        languageAlert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .destructive, handler: nil))
        
        self.present(languageAlert, animated: true, completion: nil)
        
		AudioController.main.make(command: .pause)
	}
	
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
    
        profileView.profileNameTextField.delegate = self
        
        self.emitter?.send(event: LifeCycleEvent.appear)
        self.profileView.emitter?.send(event: LifeCycleEvent.appear)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !animated {
            let BarButtonItemAppearance = UIBarButtonItem.appearance()
            BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        }
        
        self.emitter?.send(event: LifeCycleEvent.disappear)
        self.profileView.emitter?.send(event: LifeCycleEvent.disappear)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ProfileViewController: LikesVMDelegate
{
    func reload() {
        self.tableView.reloadData()
    }
    
    func make(updates: [CollectionUpdate : [Int]]) {
//                tableView.beginUpdates()
        for key in updates.keys {
            if let indexes = updates[key]?.map({IndexPath(row: $0, section: 0)}) {
                switch key {
                case .insert:
                    tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                case .delete:
                    tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                case .update:
//                    tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                    if indexes.count != 0 {
                        tableView.reloadData()

                    }
                    break
//                    tableView.reloadData()
                    //                    break
                }
            }
        }
//                tableView.endUpdates()
    }
}

extension ProfileViewController: ProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func addImage() {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = AppColor.Element.redBlur.withAlphaComponent(1)
        
        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
        let messageAttrString = NSMutableAttributedString(string: "Choose Image".localized, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedTitle")
        
        
        alert.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery".localized, style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: nil))
        
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
		print("\(info)")
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let image = UIImagePNGRepresentation(pickedImage)!
//			self.profileView.profileImageView.image = pickedImage
            self.profileView.emitter?.send(event: ProfileEvent.setImage(image))
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard(textField)
        return true
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
		return self.viewModel.tracks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID) as! SmallTrackTableViewCell
        cell.fill(vm: self.viewModel.tracks[indexPath.item])
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsEngine.sendEvent(event: .profileEvent(on: .like))
        self.emitter?.send(event: LikesTrackEvent.trackSelected(index: indexPath.item))
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        header.fill(count: Int64(self.viewModel.tracks.count).formatAmount(), length: self.viewModel.length)
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
		let track = self.viewModel.tracks[indexPath.item]
		return Common.height(text: track.name, width: tableView.frame.width)
	}
}
