//
//  ChannelsCollectionView.swift
//  blockchainapp
//
//  Created by Polina on 25.01.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class ChannelsCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, ChannelsViewProtocol {
    
    var delegate: ChannelProtocol?
    
    func display(channels: [Station]) {
        source = channels
        channelsCollectionView.reloadData()
        
        refreshControl?.endRefreshing()
    }
    
    func select(rows: [Int]) {
        
    }
    
    var source = [Station]()
    
    let channelLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.sectionNotBold
        label.text = "Channels"
        label.textAlignment = .left
        return label
    }()
    
    let seeAlsoButton: UIButton = {
        let button = UIButton()
        button.setTitle("see all", for: .normal)
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
    
    var presenter: ChannelsPresenter!
    var refreshControl: UIRefreshControl!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        presenter = ChannelsPresenter(view: self)
        presenter.getData { [weak self] (channels) in
            self?.display(channels: channels)
        }
        
        self.backgroundColor = AppColor.Element.backgroundColor
        
        seeAlsoButton.addTarget(self, action: #selector(onSeeAllBtnTouched(_:)), for: .touchUpInside)
        self.addSubview(seeAlsoButton)
        seeAlsoButton.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.right.equalTo(-10)
            make.width.equalTo(60)
            make.height.equalTo(39)
        }
        
        self.addSubview(channelLabel)
        channelLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(16)
            make.right.equalTo(seeAlsoButton.snp.left)
            make.height.equalTo(41)
        }
        
        self.addSubview(channelsCollectionView)
        channelsCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(channelLabel.snp.bottom).inset(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(self.snp.bottom).inset(6)
        }
        
        channelsCollectionView.reloadData()
    }
    
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        presenter.getData { [weak self] (channels) in
            self?.display(channels: channels)
        }
    }
    
    @objc func onSeeAllBtnTouched(_ sender: Any) {
        AnalyticsEngine.sendEvent(event: .trendEvent(event: .seeAll))
        delegate?.showAllChannels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Channel", for: indexPath) as! ChannelsCollectionViewCell
        
        cell.configureWith(image: source[indexPath.row].image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AnalyticsEngine.sendEvent(event: .trendEvent(event: .channelTapped))
        delegate?.showChannel(station: source[indexPath.row])
    }
}
