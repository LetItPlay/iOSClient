//
//  TrackInfoHeaderView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SDWebImage

class TrackInfoHeaderView: UIView {
    
    var emitter: TrackInfoEmitterProtocol?
    var viewModel: TrackInfoViewModel!
    
    var delegate: TrackLikedDelegate?
    
    let _scrollView = UIScrollView()
    
    let _channelIconImageView: UIImageView = {
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
    
    let _channelTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = AppFont.Title.mid
        return label
    }()
    
    let _followButton = FollowButton()
    
    let _infoTitle: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.mid
        label.textColor = .black
        label.backgroundColor = .clear
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 10
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    var dataLabels: [IconLabelType: IconedLabel] = [:]
    
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
        textView.text = ""
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
        let emptyLabel = EmptyLabel(title: "Loading...")
        self.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        })
        
        self.refresh(show: true)
        
        let likesCount = IconedLabel(type: .likes)
        let listenCount = IconedLabel(type: .listens)

        self.dataLabels = [.likes: likesCount, .listens: listenCount]
        
        let upperView = UIView()
        self.addSubview(upperView)
        upperView.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(self)
            make.height.equalTo(76)
        })

        upperView.addSubview(_channelIconImageView)
        _channelIconImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(16)
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.centerY.equalToSuperview()
        })

        _followButton.addTarget(self, action: #selector(followButtonTouched), for: .touchUpInside)
        upperView.addSubview(_followButton)
        _followButton.snp.makeConstraints({ (make) in
            make.right.equalTo(self).inset(16)
            make.centerY.equalToSuperview()
        })

        upperView.addSubview(_channelTitleLabel)
        _channelTitleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(_channelIconImageView.snp.right).inset(-10)
            make.right.equalToSuperview().inset(124)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
        })
        
        let invisibleChannelButton = UIButton()
        invisibleChannelButton.alpha = 1
        invisibleChannelButton.addTarget(self, action: #selector(channelPressed), for: .touchUpInside)
        upperView.addSubview(invisibleChannelButton)
        invisibleChannelButton.snp.makeConstraints({ (make) in
            make.left.equalTo(_channelIconImageView.snp.left)
            make.top.equalTo(_channelIconImageView.snp.top)
            make.right.equalTo(_channelTitleLabel.snp.right)
            make.height.equalTo(_channelIconImageView.snp.height)
        })

        let firstLine = UIView()
        firstLine.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        upperView.addSubview(firstLine)
        firstLine.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(self).inset(17)
            make.right.equalTo(self).inset(17)
            make.height.equalTo(2)
        })
        
        self.addSubview(_infoTitle)
        _infoTitle.snp.makeConstraints({ (make) in
            make.top.equalTo(upperView.snp.bottom).inset(-16)
            make.left.equalTo(16)
            make.right.equalTo(self).inset(16)
        })

        self.addSubview(likesCount)
        likesCount.snp.makeConstraints { (make) in
            make.top.equalTo(_infoTitle.snp.bottom).inset(-8)
            make.left.equalTo(16)
        }

        self.addSubview(listenCount)
        listenCount.snp.makeConstraints { (make) in
            make.left.equalTo(likesCount.snp.right).inset(-12)
            make.centerY.equalTo(likesCount)
        }

        _scrollView.backgroundColor = .white
        self.addSubview(_scrollView)
        _scrollView.snp.makeConstraints({ (make) in
            make.top.equalTo(listenCount.snp.bottom).inset(-4)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        let viewForTextView = UIView()
        _scrollView.addSubview(viewForTextView)
        viewForTextView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalToSuperview()
            make.width.equalTo(self.frame.width)
        })
        
        viewForTextView.addSubview(_infoTextView)
        _infoTextView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalTo(self).inset(16)
            make.right.equalTo(self).inset(16)
            make.bottom.equalTo(-16)
        })
    }
    
    func refresh(show: Bool) {
        _scrollView.isHidden = show
    }
    
    @objc func followButtonTouched() {
        _followButton.isSelected = !_followButton.isSelected
        self.emitter?.send(event: TrackInfoEvent.channelFollowButtonPressed)
    }
    
    @objc func channelPressed() {
        self.emitter?.send(event: TrackInfoEvent.showChannel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TrackInfoHeaderView: TrackInfoVMDelegate {
    func update(data: TrackInfoResultUpdate) {
        self.refresh(show: false)
        
        switch data {
        case .track:
            _infoTitle.text = viewModel.track.name
            _infoTextView.attributedText = viewModel.trackDescription
            
            dataLabels[.listens]?.set(text: viewModel.track.listensCount)
            dataLabels[.likes]?.set(text: viewModel.track.likesCount)
            
            delegate?.track(liked: viewModel.track.isLiked)
            
        case .channel:
            _channelIconImageView.sd_setImage(with: viewModel.channel.imageURL, placeholderImage: UIImage(named: "channelPreviewImg"), options: SDWebImageOptions.refreshCached, completed: nil)
            _channelTitleLabel.text = viewModel.channel.name
            
            _followButton.set(title: self.viewModel.channel.getMainButtonTitle())
            
        case .channelSubscription:
            _followButton.set(title: self.viewModel.channel.getMainButtonTitle())
        }
    }
}
