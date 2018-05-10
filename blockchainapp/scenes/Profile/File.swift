////
////  ProfileHeaderView.swift
////  blockchainapp
////
////  Created by Polina Abrosimova on 01.03.18.
////  Copyright © 2018 Ivan Gorbulin. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//protocol ProfileViewDelegate {
//    func addImage()
//    func changeHeaderHeigth()
//}
//
//class ProfileHeaderView: UIView {
//
//    var delegate: ProfileViewDelegate?
//
//    var emitter: ProfileEmitterProtocol?
//    var viewModel: ProfileViewModel!
//
//    var authorizedViewHeight: CGFloat = 564
//    var nonauthorizedViewHeight: CGFloat = 515
//
//    let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.layer.cornerRadius = 120
//        imageView.layer.masksToBounds = true
//        imageView.layer.shadowColor = UIColor.black.cgColor
//        imageView.layer.shadowOffset = CGSize.zero
//        imageView.layer.shadowRadius = 10.0
//        imageView.layer.shadowOpacity = 0.1
//        imageView.layer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: -10, y: -10), size: CGSize.init(width: 260, height: 260)), cornerRadius: 130).cgPath
//        imageView.layer.shouldRasterize = true
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
//
//    let changePhotoButton: UIButton = {
//        let button = UIButton()
//        button.layer.cornerRadius = 20
//        button.setImage(UIImage.init(named: "editPhotoInactive"), for: .normal)
//        button.backgroundColor = .red
//        return button
//    }()
//
//    let bluredImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.layer.cornerRadius = 140
//        imageView.layer.masksToBounds = true
//        return imageView
//    }()
//
//    let profileNameTextField: UITextField = {
//        let textField = UITextField()
//        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        textField.textAlignment = .center
//        textField.returnKeyType = .done
//        return textField
//    }()
//
//    let lineForTextField: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.red.withAlphaComponent(0.2)
//        return view
//    }()
//
//    var authButtonConstraint: NSLayoutConstraint!
//
//    let authorizationButton: UIButton = {
//        let button = UIButton()
//        button.titleLabel?.font = AppFont.Button.mid
//        button.setTitleColor(.red, for: .normal)
//        button.titleLabel?.textAlignment = .center
//        button.layer.cornerRadius = 5
//        button.layer.borderColor = UIColor.red.cgColor
//        button.layer.borderWidth = 1
//        button.contentEdgeInsets = UIEdgeInsetsMake(3, 12.5, 3, 12.5)
//        return button
//    }()
//
//    let languageButton: UIButton = {
//        let button = UIButton()
//        button.titleLabel?.font = AppFont.Button.mid
//        button.setTitleColor(.red, for: .normal)
//        button.setTitle("Change content language".localized, for: .normal)
//        button.titleLabel?.textAlignment = .center
//        button.layer.cornerRadius = 5
//        button.layer.borderColor = UIColor.red.cgColor
//        button.layer.borderWidth = 1
//        button.contentEdgeInsets = UIEdgeInsetsMake(3, 12.5, 3, 12.5)
//        return button
//    }()
//
//    let languageTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = AppFont.Button.mid
//        label.textColor = AppColor.Title.lightGray
//        return label
//    }()
//
//    let bottomSeparator: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1)
//        return view
//    }()
//
//    init(emitter: ProfileEmitterProtocol, viewModel: ProfileViewModel) {
//        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: viewModel.isAuthorized ? nonauthorizedViewHeight : authorizedViewHeight)))
//
//        self.emitter = emitter
//        self.viewModel = viewModel
//        viewModel.delegate = self
//
//        self.viewInitialize()
//
//        emitter.send(event: LifeCycleEvent.initialize)
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    func viewInitialize()
//    {
//        self.addSubview(bluredImageView)
//        bluredImageView.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().inset(68)
//            make.width.equalTo(260)
//            make.height.equalTo(260)
//        }
//
//        let blur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .regular))
//        self.addSubview(blur)
//        blur.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//
//        blur.contentView.addSubview(profileImageView)
//        profileImageView.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().inset(48)
//            make.width.equalTo(240)
//            make.height.equalTo(240)
//        }
//
//        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped(_:)), for: .touchUpInside)
//        blur.contentView.addSubview(self.changePhotoButton)
//        self.changePhotoButton.snp.makeConstraints { (make) in
//            make.right.equalTo(profileImageView)
//            make.bottom.equalTo(profileImageView).inset(30)
//            make.width.equalTo(40)
//            make.height.equalTo(40)
//        }
//
//        blur.contentView.addSubview(lineForTextField)
//
//        blur.contentView.addSubview(profileNameTextField)
//        profileNameTextField.snp.makeConstraints { (make) in
//            make.top.equalTo(profileImageView.snp.bottom).inset(-52)
//            make.right.equalTo(profileImageView.snp.right)
//            make.left.equalTo(profileImageView.snp.left)
//        }
//
//        lineForTextField.snp.makeConstraints { (make) in
//            make.bottom.equalTo(profileNameTextField).inset(-1)
//            make.left.equalTo(profileNameTextField).inset(-14)
//            make.right.equalTo(profileNameTextField).inset(-14)
//            make.height.equalTo(14)
//        }
//
//        authorizationButton.addTarget(self, action: #selector(self.authorizationButtonPressed), for: .touchUpInside)
//        blur.contentView.addSubview(authorizationButton)
//        authorizationButton.snp.makeConstraints { (make) in
//            authButtonConstraint = make.top.equalTo(profileImageView.snp.bottom).inset(-50).constraint.layoutConstraints.first
//            make.centerX.equalToSuperview()
//        }
//
//        blur.contentView.addSubview(languageButton)
//        languageButton.snp.makeConstraints { (make) in
//            make.top.equalTo(authorizationButton.snp.bottom).inset(-20)
//            make.centerX.equalToSuperview()
//        }
//
//        authorizationButton.snp.makeConstraints { (make) in
//            make.width.equalTo(languageButton.snp.width)
//        }
//
//        blur.contentView.addSubview(languageTitleLabel)
//        languageTitleLabel.snp.makeConstraints({ (make) in
//            make.top.equalTo(languageButton.snp.bottom).inset(-10)
//            make.centerX.equalToSuperview()
//        })
//
//        blur.contentView.addSubview(bottomSeparator)
//        bottomSeparator.snp.makeConstraints { (make) in
//            make.height.equalTo(1)
//            make.bottom.equalToSuperview()
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc func changePhotoButtonTapped(_ sender: Any) {
//        AnalyticsEngine.sendEvent(event: .profileEvent(on: .avatar))
//        delegate?.addImage()
//    }
//
//    @objc func authorizationButtonPressed() {
//        self.emitter?.send(event: ProfileEvent.authButtonPressed)
//    }
//
//    func setName(name: String)
//    {
//        if name != "name"
//        {
//            profileNameTextField.text = name
//        }
//        else
//        {
//            profileNameTextField.placeholder = "name".localized
//        }
//    }
//
//    func setElementsAppearance() {
//        self.changePhotoButton.isHidden = !self.viewModel.isAuthorized
//        self.profileNameTextField.isHidden = !self.viewModel.isAuthorized
//        self.lineForTextField.isHidden = !self.viewModel.isAuthorized
//    }
//}
//
//extension ProfileHeaderView: ProfileVMDelegate
//{
//    func make(updates: [ProfileUpdate]) {
//        for data in updates {
//            switch data {
//            case .image:
//                let image = UIImage.init(data: self.viewModel.imageData!)
//                profileImageView.image = image
//                bluredImageView.image = image
//            case .language:
//                self.languageTitleLabel.text = self.viewModel.currentLanguage
//                break
//            case .name:
//                self.setName(name: self.viewModel.name)
//            case .authorization:
//                let newFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.viewModel.isAuthorized ? authorizedViewHeight : nonauthorizedViewHeight)
//                self.frame = newFrame
//
//                self.authButtonConstraint.constant = self.viewModel.isAuthorized ? 117 : 50
//                self.authorizationButton.setTitle(self.viewModel.textForAuthButton, for: .normal)
//                self.setElementsAppearance()
//
//                self.delegate?.changeHeaderHeigth()
//            }
//        }
//    }
//}
