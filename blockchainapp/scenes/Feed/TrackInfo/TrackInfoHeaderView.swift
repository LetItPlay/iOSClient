//
//  TrackInfoHeaderView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class TrackInfoHeaderView: UIView {
    
    var emitter: TrackInfoEmitterProtocol?
    var viewModel: TrackInfoViewModel!
    
    let _channelIconView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 20
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.snp.makeConstraints({ (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
        })
        return imgView
    }()
    
    let _channelTitleLabel: UILabel = UILabel()
    let _channelFollowLabel: UILabel = UILabel()
    
    let _followButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.layer.borderColor = AppColor.Element.subscribe.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.setBackgroundImage(AppColor.Element.subscribe.img(), for: .normal)
        button.setBackgroundImage(UIColor.clear.img(), for: .selected)
        button.setTitle("Follow".localized, for: .normal)
        button.setTitle("Following".localized, for: .selected)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(AppColor.Element.subscribe, for: .selected)
        button.contentEdgeInsets.left = 12
        button.contentEdgeInsets.right = 12
        button.titleLabel?.font = AppFont.Button.mid
        return button
    }()
    
    let _infoTitle: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.sml
        label.textColor = .black
        label.backgroundColor = .clear
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 2
        label.text = "Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго "
        label.sizeToFit()
        return label
    }()
    
    let _infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = AppFont.Title.info
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.blue, NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleNone.rawValue]
        textView.text = "Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин  Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин  Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин  Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин "
        return textView
    }()

    init(emitter: TrackInfoEmitterProtocol, viewModel: TrackInfoViewModel) {
        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 320, height: 511)))
        
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.viewInitialize()
        
        emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.addSubview(_channelIconView)
        _channelIconView.snp.makeConstraints({ (make) in
            make.top.equalTo(50)
            make.left.equalTo(16)
            make.width.equalTo(100)
            make.height.equalTo(100)
        })
        
        self.addSubview(_followButton)
        _followButton.snp.makeConstraints({ (make) in
            make.top.equalTo(50)
            make.right.equalTo(-16)
            make.height.equalTo(32)
        })
        
        self.addSubview(_channelTitleLabel)
        _channelTitleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(60)
            make.left.equalTo(_channelIconView.snp.right)
            make.right.equalTo(_followButton.snp.left).inset(-10)
        })
        
        self.addSubview(_channelFollowLabel)
        _channelFollowLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(_channelTitleLabel.snp.bottom).inset(-10)
            make.left.equalTo(_channelTitleLabel)
        })
        
        let view = UIView()
        view.backgroundColor = .red
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalTo(_channelIconView.snp.bottom).inset(-16)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(1)

        })
        
        self.addSubview(_infoTitle)
        _infoTitle.snp.makeConstraints({ (make) in
            make.top.equalTo(view.snp.bottom).inset(-20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        })
        
        self.addSubview(_infoTextView)
        _infoTextView.snp.makeConstraints({ (make) in
            make.top.equalTo(_infoTitle.snp.bottom).inset(-16)
            make.left.equalTo(16)
            make.right.equalTo(-16)
//            make.bottom.equalTo(-16)
            make.height.equalTo(500)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TrackInfoHeaderView: TrackInfoVMDelegate {
    func update(data: TrackInfoResultUpdate) {
        switch data {
        case .track:
            _infoTitle.text = viewModel.track.name
            _infoTextView.text = viewModel.track.description
            
        case .channel:
            _channelIconView.sd_setImage(with: viewModel.channel.imageURL)
            _channelTitleLabel.text = viewModel.channel.name
            _channelFollowLabel.text = viewModel.channel.subscriptionCount
            _followButton.isSelected = viewModel.channel.isSubscribed
        }
        
        
    }
}
