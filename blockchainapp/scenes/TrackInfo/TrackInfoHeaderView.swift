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
    
    var delegate: TrackLikedDelegate?
    
    let refreshControll = UIRefreshControl()
    
    let _scrollView = UIScrollView()
    var heightForInfoTextView: NSLayoutConstraint!
    
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
    
    let _channelTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = AppFont.Title.mid
        return label
    }()
    
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
        button.addTarget(self, action: #selector(followButtonTouched), for: .touchUpInside)
        return button
    }()
    
    let _infoTitle: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.mid
        label.textColor = .black
        label.backgroundColor = .clear
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 2
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
//        _scrollView.refreshControl = refreshControll
        
        let emptyLabel = UILabel()
        emptyLabel.text = "Loading..."
        emptyLabel.font = AppFont.Title.sectionNotBold
        emptyLabel.textColor = AppColor.Element.emptyMessage
        emptyLabel.textAlignment = .center
        self.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        })
        
        self.refresh(show: true)
        
        let likesCount = IconedLabel(type: .likes)
        let listenCount = IconedLabel(type: .listens)
        
        self.dataLabels = [.likes: likesCount, .listens: listenCount]
        
        _scrollView.backgroundColor = .white
        self.addSubview(_scrollView)
        _scrollView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        let upperView = UIView()
        _scrollView.addSubview(upperView)
        upperView.snp.makeConstraints({ (make) in
            make.top.equalTo(52)
            make.left.equalTo(0)
            make.right.equalTo(self)
            make.height.equalTo(76)
        })
        
        upperView.addSubview(_channelIconView)
        _channelIconView.snp.makeConstraints({ (make) in
            make.left.equalTo(16)
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.centerY.equalToSuperview()
        })
        
        upperView.addSubview(_followButton)
        _followButton.snp.makeConstraints({ (make) in
            make.right.equalTo(self).inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        })
        
        upperView.addSubview(_channelTitleLabel)
        _channelTitleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(_channelIconView.snp.right).inset(-10)
            make.right.equalTo(_followButton.snp.left).inset(-10)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
        })
        
        let line = UIView()
        line.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        upperView.addSubview(line)
        line.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(self).inset(17)
            make.right.equalTo(self).inset(17)
            make.height.equalTo(2)
        })
        
        _scrollView.addSubview(_infoTitle)
        _infoTitle.snp.makeConstraints({ (make) in
            make.top.equalTo(upperView.snp.bottom).inset(-16)
            make.left.equalTo(16)
            make.right.equalTo(self).inset(16)
        })
        
        _scrollView.addSubview(likesCount)
        likesCount.snp.makeConstraints { (make) in
            make.top.equalTo(_infoTitle.snp.bottom).inset(-8)
            make.left.equalTo(16)
        }
        
        _scrollView.addSubview(listenCount)
        listenCount.snp.makeConstraints { (make) in
            make.left.equalTo(likesCount.snp.right).inset(-12)
            make.centerY.equalTo(likesCount)
        }
        
        let viewForTextView = UIView()
        _scrollView.addSubview(viewForTextView)
        viewForTextView.snp.makeConstraints({ (make) in
            make.top.equalTo(_infoTitle.snp.bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalToSuperview()
            make.width.equalTo(self.frame.width)
        })
        
        viewForTextView.addSubview(_infoTextView)
        _infoTextView.snp.makeConstraints({ (make) in
            make.top.equalTo(_infoTitle.snp.bottom).inset(-35)
            make.left.equalTo(self).inset(16)
            make.right.equalTo(self).inset(16)
            make.bottom.equalTo(-16)
            heightForInfoTextView = make.height.equalTo(700).constraint.layoutConstraints.first
        })
    }
    
    func refresh(show: Bool) {
        _scrollView.isHidden = show
//        if show {
//            refreshControll.beginRefreshing()
//        }
//        else {
//            refreshControll.endRefreshing()
//        }
    }
    
    @objc func followButtonTouched() {
        _followButton.isSelected = !_followButton.isSelected
        self.emitter?.send(event: TrackInfoEvent.channelFollowButtonPressed)
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
            _infoTextView.text = viewModel.track.description
            self.heightForInfoTextView.constant = _infoTextView.sizeThatFits(CGSize(width: _infoTextView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
            
            dataLabels[.listens]?.set(text: viewModel.track.listensCount)
            dataLabels[.likes]?.set(text: viewModel.track.likesCount)
            
            delegate?.track(liked: viewModel.track.isLiked)
            
        case .channel:
            _channelIconView.sd_setImage(with: viewModel.channel.imageURL)
            _channelTitleLabel.text = viewModel.channel.name
            
            _followButton.isSelected = viewModel.channel.isSubscribed
            
        case .channelSubscription:
            _followButton.isSelected = viewModel.channel.isSubscribed
        }
    }
}
