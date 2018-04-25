//
//  MainPlayerBottomIconsView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class MainPlayerBottomIconsView: UIView, BottomPlayerViewDelegate {
    
    var emitter: MainPlayerBottomIconsEmitter!
    var vm: PlayerViewModel!
    
    var speeds: [(text: String, value: Float)] = [(text: "x 0.25", value: 0.25), (text: "x 0.5", value: 0.5), (text: "x 0.75", value: 0.75), (text: "Default".localized, value: 1), (text: "x 1.25", value: 1.25), (text: "x 1.5", value: 1.5), (text: "x 2", value: 2)]

    var trackLikeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "likeInactiveFeed"), for: .normal)
        button.addTarget(self, action: #selector(trackLikeButtonTouched), for: .touchUpInside)
        return button
    }()
    
    var trackSpeedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "timespeedInactive"), for: .normal)
        button.addTarget(self, action: #selector(trackSpeedButtonTouched), for: .touchUpInside)
        return button
    }()
    
    var showOthersButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "otherInactive"), for: .normal)
        button.addTarget(self, action: #selector(showOthersButtonTouched), for: .touchUpInside)
        return button
    }()
    
    convenience init(vm: PlayerViewModel, emitter: MainPlayerBottomIconsEmitter) {
        self.init(frame: CGRect.zero)
        self.vm = vm
        self.vm.bottomDelegate = self
        self.emitter = emitter
    }
    
    func update() {
        self.trackLikeButton.isSelected = self.vm.track.isLiked
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(trackLikeButton)
        trackLikeButton.snp.makeConstraints({ (make) in
            make.left.equalTo(self.frame.width / 10 - 12)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        })
        
        self.addSubview(trackSpeedButton)
        trackSpeedButton.snp.makeConstraints({ (make) in
            make.left.equalTo(self.frame.width / 4)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        })
        
        self.addSubview(showOthersButton)
        showOthersButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(self.frame.width / 10 - 12)
            make.bottom.equalTo(-8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideIcons(_ hide: Bool) {
        let alphaConst: CGFloat = hide ? 0 : 1
        
        UIView.animate(withDuration: 0.5) {
            self.showOthersButton.alpha = alphaConst
            self.trackLikeButton.alpha = alphaConst
            self.trackSpeedButton.alpha = alphaConst
        }
    }
    
    func hideIcons(_ constant: CGFloat) {
//        print(constant)
        self.showOthersButton.alpha = constant
        self.trackLikeButton.alpha = constant
        self.trackSpeedButton.alpha = constant
    }
    
    @objc func trackLikeButtonTouched() {
        self.emitter.send(event: .likeButtonTouched)
    }
    
    @objc func trackSpeedButtonTouched()
    {
        let currentSpeed = AudioController.main.player.chosenRate == -1 ? 1 : AudioController.main.player.chosenRate
        
        let speedAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        speedAlert.view.tintColor = AppColor.Title.lightGray
        
        let messageFont = [NSAttributedStringKey.font: AppFont.Title.small, NSAttributedStringKey.foregroundColor: AppColor.Title.lightGray]
        let messageAttrString = NSMutableAttributedString(string: "The playback speed of audio".localized, attributes: messageFont)
        speedAlert.setValue(messageAttrString, forKey: "attributedTitle")
        
        for speed in speeds {
            if speed.value == currentSpeed {
                speedAlert.addAction(UIAlertAction(title: speed.text, style: .default, handler: { _ in
                    self.change(speed: speed.value)
                }))
            }
            else {
                speedAlert.addAction(UIAlertAction(title: speed.text, style: .destructive, handler: { _ in
                    self.change(speed: speed.value)
                }))
            }
        }
        
        speedAlert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .destructive, handler: nil))
        
        self.emitter.send(event: .speedButtonTouched)
    }
    
    func change(speed: Float) {
        AudioController.main.player.set(rate: speed)
    }
    
    @objc func showOthersButtonTouched() {
        self.emitter.send(event: .showOthersButtonTouched)
    }
}
