//
//  AuthorizationViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 04.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class AuthorizationViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "redTriangle")
        return imageView
    }()
    
    let logoTextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "textLogo")
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes:[NSAttributedStringKey.foregroundColor: AppColor.Title.gray])
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSAttributedStringKey.foregroundColor: AppColor.Title.gray])
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login".localized, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.setBackgroundImage(AppColor.Element.subscribe.img(), for: .normal)
        button.setBackgroundImage(UIColor.clear.img(), for: .selected)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = AppFont.Title.section
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot password?".localized, for: .normal)
        button.setTitleColor(AppColor.Element.redBlur.withAlphaComponent(1), for: .normal)
        button.titleLabel?.font = AppFont.Button.mid
        return button
    }()
    
    let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create a new account".localized, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewInitialize()
    }
    
    func viewInitialize() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(36)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        self.view.addSubview(logoTextImageView)
        logoTextImageView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).inset(-30)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(logoTextImageView.snp.bottom).inset(-70.4)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(36)
        }
        
        let emailLine = UIView()
        emailLine.backgroundColor = AppColor.Title.lightGray
        self.view.addSubview(emailLine)
        emailLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalTo(emailTextField.snp.left)
            make.right.equalTo(emailTextField.snp.right)
            make.bottom.equalTo(emailTextField.snp.bottom)
        }
        
        self.view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).inset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
        
        let passwordLine = UIView()
        passwordLine.backgroundColor = AppColor.Title.lightGray
        self.view.addSubview(passwordLine)
        passwordLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalTo(passwordTextField.snp.left)
            make.right.equalTo(passwordTextField.snp.right)
            make.bottom.equalTo(passwordTextField.snp.bottom)
        }
        
        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).inset(-40)
            make.centerX.equalToSuperview()
            make.width.equalTo(emailTextField)
            make.height.equalTo(46)
        }
        
        self.view.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).inset(-26)
            make.centerX.equalToSuperview()
            make.width.equalTo(emailTextField)
        }
        
        self.view.addSubview(createAccountButton)
        createAccountButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(46)
        }
        
//        let createAccountLine = UIView()
//        createAccountLine.backgroundColor = AppColor.Title.lightGray
//        self.view.addSubview(passwordLine)
//        createAccountLine.snp.makeConstraints { (make) in
//            make.height.equalTo(1)
//            make.left.equalTo(createAccountButton.snp.left)
//            make.right.equalTo(createAccountButton.snp.right)
//            make.bottom.equalTo(createAccountButton.snp.top)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
