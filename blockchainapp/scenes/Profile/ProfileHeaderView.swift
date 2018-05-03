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
    
    let profileImageView: UIImageView = UIImageView()
    let bluredImageView: UIImageView = UIImageView()
    let profileNameTextField: UITextField = UITextField()
    let changePhotoButton: UIButton = UIButton()
    let languageButton: UIButton = UIButton()
    let languageTitleLabel: UILabel = UILabel()
    
    init(emitter: ProfileEmitterProtocol, viewModel: ProfileViewModel) {
        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 511)))
        
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.viewInitialize()
        
        emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
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
        
        profileImageView.layer.cornerRadius = 120
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .white
        
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
        
        blur.contentView.addSubview(profileNameTextField)
        profileNameTextField.snp.makeConstraints { (make) in
            //            make.centerX.equalTo(profileImageView)
            make.top.equalTo(profileImageView.snp.bottom).inset(-52)
            make.right.equalTo(profileImageView.snp.right)
            make.left.equalTo(profileImageView.snp.left)
        }
        
        profileNameTextField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        profileNameTextField.textAlignment = .center
        profileNameTextField.returnKeyType = .done
        
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
        
        languageButton.setBackgroundImage(UIColor.init(white: 2.0/255, alpha: 0.1).img(), for: .normal)
        languageButton.layer.cornerRadius = 6
        languageButton.layer.masksToBounds = true
        languageButton.titleLabel?.font = AppFont.Button.mid
        languageButton.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        languageButton.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 17, bottom: 6, right: 17)
        languageButton.semanticContentAttribute = .forceRightToLeft
        languageButton.setTitle("Select language", for: .normal)
        
        languageTitleLabel.font = AppFont.Button.mid
        languageTitleLabel.textColor = AppColor.Title.lightGray
        
        let bot = CALayer()
        bot.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 510), size: CGSize.init(width: 414, height: 1))
        bot.backgroundColor = UIColor.init(white: 232.0/255, alpha: 1).cgColor
        blur.contentView.layer.addSublayer(bot)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changePhotoButtonTapped(_ sender: Any) {
        AnalyticsEngine.sendEvent(event: .profileEvent(on: .avatar))
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
//                self.languageButton.setTitle(self.viewModel.languageString, for: .normal)
                break
            case .name:
                self.setName(name: self.viewModel.name)
            }
        }
    }
}
