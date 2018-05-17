//
//  ProfileHeaderView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 01.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class ProfileHeaderView: UIView {
    
    var delegate: ProfileViewDelegate?
    
    var emitter: ProfileEmitterProtocol?
    var viewModel: ProfileViewModel!
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 120
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let bluredImageView: UIImageView = {
        let bluredImageView = UIImageView()
        bluredImageView.layer.cornerRadius = 140
        bluredImageView.layer.masksToBounds = true
        return bluredImageView
    }()
    
    let profileNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.textAlignment = .center
        textField.returnKeyType = .done
        return textField
    }()
    
    let lineForTextField: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        return view
    }()
    
    let changePhotoButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage.init(named: "editPhotoInactive"), for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    let languageButton = ProfileButton(title: LocalizedStrings.Profile.changeLanguage)
    
    let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.Button.mid
        label.textColor = AppColor.Title.lightGray
        return label
    }()
    
    let hiddenChannelsButton = ProfileButton(title: LocalizedStrings.Channels.hidden)
    
    init(emitter: ProfileEmitterProtocol, viewModel: ProfileViewModel) {
        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 511 + 52)))
        
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.viewInitialize()
        
        emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize() {
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
        
        let shadowLayer = CALayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize.zero
        shadowLayer.shadowRadius = 10.0
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: self.frame.width / 2 - 130, y: 68), size: CGSize.init(width: 260, height: 260)), cornerRadius: 130).cgPath
        shadowLayer.shouldRasterize = true
        blur.layer.addSublayer(shadowLayer)
        
        blur.contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(78)
            make.width.equalTo(240)
            make.height.equalTo(240)
        }
        
        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped(_:)), for: .touchUpInside)
        blur.contentView.addSubview(self.changePhotoButton)
        self.changePhotoButton.snp.makeConstraints { (make) in
            make.right.equalTo(profileImageView)
            make.bottom.equalTo(profileImageView).inset(30)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        blur.contentView.addSubview(lineForTextField)
        
        blur.contentView.addSubview(profileNameTextField)
        profileNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).inset(-52)
            make.right.equalTo(profileImageView.snp.right)
            make.left.equalTo(profileImageView.snp.left)
        }
        
        lineForTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(profileNameTextField).inset(-1)
            make.left.equalTo(profileNameTextField).inset(-14)
            make.right.equalTo(profileNameTextField).inset(-14)
            make.height.equalTo(14)
        }
        
        self.hiddenChannelsButton.addTarget(self, action: #selector(self.hiddenChannelsButtonTapped(_:)), for: .touchUpInside)
        blur.contentView.addSubview(hiddenChannelsButton)

        blur.contentView.addSubview(languageButton)
        languageButton.snp.makeConstraints { (make) in
            make.top.equalTo(lineForTextField.snp.bottom).inset(-24)
            make.centerX.equalToSuperview()
            make.width.equalTo(hiddenChannelsButton.snp.width)
        }
        
        blur.contentView.addSubview(languageTitleLabel)
        languageTitleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(languageButton.snp.bottom).inset(-14)
            make.centerX.equalToSuperview()
        })
        
        hiddenChannelsButton.snp.makeConstraints { (make) in
            make.top.equalTo(languageTitleLabel.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1)
        blur.contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(self.frame.width - 30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changePhotoButtonTapped(_ sender: Any) {
        delegate?.addImage()
    }
    
    @objc func hiddenChannelsButtonTapped(_ sender: Any) {
        self.emitter?.send(event: ProfileEvent.showHiddenChannels)
    }
    
    func setName(name: String)
    {
        if name != "name"
        {
            profileNameTextField.text = name
        }
        else
        {
            profileNameTextField.placeholder = LocalizedStrings.Profile.name
        }
    }
}

extension ProfileHeaderView: ProfileVMDelegate
{
    func make(updates: [ProfileUpdate]) {
        for data in updates {
            switch data {
            case .image:
                let image = UIImage.init(data: self.viewModel.imageData!)
                profileImageView.image = image
                bluredImageView.image = image
            case .language:
                self.languageTitleLabel.text = self.viewModel.currentLanguage
                break
            case .name:
                self.setName(name: self.viewModel.name)
            }
        }
    }
}
