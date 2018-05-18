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
    
    let tableView = BaseTableView(frame: CGRect.zero, style: .grouped)
    var tableProvider: TableProvider!
    
    var profileHeader: ProfileHeaderView!
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
        self.profileHeader = view
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = { (indexPath, event, data) in
            switch event {
            case "onSelected":
                self.emitter?.send(event: TrackEvent.trackSelected(index: indexPath.item))
            case "onOthers":
                self.emitter?.send(event: TrackEvent.showOthers(index: indexPath.row))
            default:
                break
            }
        }
        self.tableProvider.beginDragging = {(scrollView) in
            if self.isKeyboardShown {
                self.dismissKeyboard(scrollView)
            }
        }
        
        self.emitter?.send(event: LifeCycleEvent.initialize)
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
        self.profileHeader.addGestureRecognizer(tap)
        
        imagePicker.delegate = self
        profileHeader.delegate = self
        
        self.tableView.tableHeaderView = profileHeader
        
        self.tableView.separatorColor = UIColor.init(red: 243.0/255, green: 71.0/255, blue: 36.0/255, alpha: 0.2)
        
        self.tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
        
        self.tableView.reloadData()
        
        let view = UIView()
        self.view.addSubview(view)
        view.backgroundColor = UIColor.white
        view.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        self.profileHeader.languageButton.addTarget(self, action: #selector(langChanged(_:)), for: .touchUpInside)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShown = true
        tableView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    @objc func dismissKeyboard(_ sender: Any) {
        if isKeyboardShown && self.profileHeader.profileNameTextField.isFirstResponder {
            isKeyboardShown = false
            view.endEditing(true)
            let height = sender is UITapGestureRecognizer ? 0 : 100
            tableView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
            let name = self.profileHeader.profileNameTextField.text!
            self.profileHeader.emitter?.send(event: ProfileEvent.setName(name))
        }
    }
    
    @objc func langChanged(_: UIButton) {
        let currentLanguage = UserSettings.language.name
        
        let languageAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        languageAlert.view.tintColor = AppColor.Title.lightGray
        
        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
        let messageAttrString = NSMutableAttributedString(string: LocalizedStrings.Profile.selectLanguageTitle, attributes: messageFont)
        languageAlert.setValue(messageAttrString, forKey: "attributedTitle")
        
        for language in UserSettings.languages.map({$0.name}) {
            if language == currentLanguage {
                languageAlert.addAction(UIAlertAction(title: language, style: .default, handler: { _ in
                }))
            }
            else {
                languageAlert.addAction(UIAlertAction(title: language, style: .destructive, handler: { _ in
                    self.profileHeader.emitter?.send(event: ProfileEvent.set(language: language))
                    self.emitter?.send(event: LikesTrackEvent.hidePlayer)
                }))
            }
        }
        
        languageAlert.addAction(UIAlertAction.init(title: LocalizedStrings.SystemMessage.cancel, style: .destructive, handler: nil))
        
        self.present(languageAlert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
        
        profileHeader.profileNameTextField.delegate = self
        
        self.emitter?.send(event: LifeCycleEvent.appear)
        self.profileHeader.emitter?.send(event: LifeCycleEvent.appear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.emitter?.send(event: LifeCycleEvent.disappear)
        self.profileHeader.emitter?.send(event: LifeCycleEvent.disappear)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ProfileViewController: TrackHandlingViewModelDelegate {
    func reload(cells: [CollectionUpdate : [Int]]?) {
        if let keys = cells?.keys {
            tableView.beginUpdates()
            for key in keys {
                if let indexes = cells![key]?.map({IndexPath(row: $0, section: 0)}) {
                    switch key {
                    case .insert:
                        tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                    case .delete:
                        tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                    case .update:
                        tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                        //                        if indexes.count != 0 {
                        //                            tableView.reloadData()
                        
                        //                        }
                        //                        break
                        //                    tableView.reloadData()
                        //                    break
                    }
                }
            }
            tableView.endUpdates()
        }
    }
    
    func reloadAppearence() {
        
    }
    
    func reload() {
        self.tableView.reloadData()
    }
}

extension ProfileViewController: LikesVMDelegate
{
    
    
    func make(updates: [CollectionUpdate : [Int]]) {
        
    }
}

extension ProfileViewController: ProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func addImage() {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = AppColor.Element.redBlur.withAlphaComponent(1)
        
        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
        let messageAttrString = NSMutableAttributedString(string: LocalizedStrings.Profile.chooseImage, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedTitle")
        
        
        alert.addAction(UIAlertAction(title: LocalizedStrings.Profile.camera, style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedStrings.Profile.gallery, style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: LocalizedStrings.SystemMessage.cancel, style: .cancel, handler: nil))
        
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
            let alert  = UIAlertController(title: LocalizedStrings.SystemMessage.warning, message: LocalizedStrings.SystemMessage.noCameraWarning, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedStrings.SystemMessage.ok, style: .default, handler: nil))
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
            self.profileHeader.emitter?.send(event: ProfileEvent.setImage(image))
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

extension ProfileViewController: TableCellProvider, TableDataProvider {
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return SmallTrackTableViewCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        
    }
    
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.data[indexPath.item]
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.data.count
    }
    
    func height(table: UITableView, forSection: Int, isHeader: Bool) -> CGFloat {
        return isHeader ? 81 : 0
    }
    
    func view(table: UITableView, forSection: Int, isHeader: Bool) -> UIView? {
        if isHeader {
            header.fill(count: Int64(self.viewModel.data.count).formatAmount(), length: self.viewModel.length)
            return header
        } else {
            return nil
        }
    }
    
}
