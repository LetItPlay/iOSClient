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
    
    let changePhotoButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage.init(named: "editPhotoInactive"), for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    let languageButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIColor.init(white: 2.0/255, alpha: 0.1).img(), for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.titleLabel?.font = AppFont.Button.mid
        button.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 17, bottom: 6, right: 17)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitle("Select language".localized, for: .normal)
        return button
    }()
    
    let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.Button.mid
        label.textColor = AppColor.Title.lightGray
        return label
    }()
    
    let hiddenChannelsButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIColor.init(white: 2.0/255, alpha: 0.1).img(), for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.titleLabel?.font = AppFont.Button.mid
        button.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 17, bottom: 6, right: 17)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitle("Hidden channels".localized, for: .normal)
        return button
    }()
    
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
        
        blur.contentView.addSubview(self.changePhotoButton)
        self.changePhotoButton.snp.makeConstraints { (make) in
            make.right.equalTo(profileImageView)
            make.bottom.equalTo(profileImageView).inset(30)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped(_:)), for: .touchUpInside)
        
        blur.contentView.addSubview(profileNameTextField)
        profileNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).inset(-52)
            make.right.equalTo(profileImageView.snp.right)
            make.left.equalTo(profileImageView.snp.left)
        }
        
        let highlight = UIView()
        highlight.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        blur.contentView.addSubview(highlight)
        highlight.snp.makeConstraints { (make) in
            make.bottom.equalTo(profileNameTextField).inset(-1)
            make.left.equalTo(profileNameTextField).inset(-14)
            make.right.equalTo(profileNameTextField).inset(-14)
            make.height.equalTo(14)
        }
        
        blur.contentView.addSubview(languageButton)
        languageButton.snp.makeConstraints { (make) in
            make.top.equalTo(highlight.snp.bottom).inset(-24)
            make.centerX.equalToSuperview()
        }
        
        blur.contentView.addSubview(languageTitleLabel)
        languageTitleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(languageButton.snp.bottom).inset(-14)
            make.centerX.equalToSuperview()
        })
        
        blur.contentView.addSubview(hiddenChannelsButton)
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
    
    func setName(name: String)
    {
        if name != "name"
        {
            profileNameTextField.text = name
        }
        else
        {
            profileNameTextField.placeholder = "name".localized
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
