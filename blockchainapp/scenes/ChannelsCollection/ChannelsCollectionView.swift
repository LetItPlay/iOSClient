//
//  ChannelsCollectionView.swift
//  blockchainapp
//
//  Created by Polina on 25.01.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class ChannelsCollectionView: UIView {
    
    var emitter: CategoryChannelsEmitterProtocol?
    var viewModel: CategoryChannelsViewModel!
    
    let channelLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.sectionNotBold
        label.text = "You are subscribed".localized
        label.textAlignment = .left
        return label
    }()
    
    let seeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("see all".localized, for: .normal)
        button.setTitleColor(AppColor.Element.redBlur.withAlphaComponent(1), for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = AppFont.Button.mid
        return button
    }()
    
    lazy var channelsCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize.init(width: 60, height: 60)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsets.init(top: 6, left: 16, bottom: 6, right: 16)
        cv.showsHorizontalScrollIndicator = false
        cv.register(ChannelsCollectionViewCell.self, forCellWithReuseIdentifier: "Channel")
        cv.backgroundColor = .clear
        return cv
    }()
    
    convenience init(frame: CGRect, emitter: CategoryChannelsEmitterProtocol, viewModel: CategoryChannelsViewModel)
    {
        self.init(frame: frame)
        self.emitter = emitter
        self.viewModel = viewModel
        viewModel.delegate = self
        
        self.viewInitialize()
        
        self.emitter?.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.backgroundColor = .white
        
        seeAllButton.addTarget(self, action: #selector(onSeeAllBtnTouched(_:)), for: .touchUpInside)
        self.addSubview(seeAllButton)
        seeAllButton.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.right.equalTo(-10)
            make.width.equalTo(60)
            make.height.equalTo(39)
        }
        
        self.addSubview(channelLabel)
        channelLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(16)
            make.right.equalTo(seeAllButton.snp.left)
            make.height.equalTo(41)
        }
        
        self.addSubview(channelsCollectionView)
        channelsCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(channelLabel.snp.bottom).inset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(self.snp.bottom).inset(6)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc func onSeeAllBtnTouched(_ sender: Any) {
        self.emitter?.send(event: ChannelsEvent.showAllChannels)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChannelsCollectionView: CategoryChannelsVMDelegate
{
    func updateEmptyMessage() {
        // TODO: without channels?
    }
    
    func reloadChannels() {
        self.channelsCollectionView.reloadData()
    }
}

extension ChannelsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.viewModel.channels.count > 50 {
            return 50
        }
        return self.viewModel.channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Channel", for: indexPath) as! ChannelsCollectionViewCell
        cell.configureWith(image: self.viewModel.channels[indexPath.row].imageURL!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.emitter?.send(event: ChannelsEvent.showChannel(index: indexPath.row))
    }
}
