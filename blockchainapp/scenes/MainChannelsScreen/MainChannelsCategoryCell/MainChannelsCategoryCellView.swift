//
//  MainChannelsCategoryCellView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 03.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class MainChannelsCategoryCellView: UIView {
    var category: ChannelCategoryViewModel!
    
    public var onSeeAll: ((String) -> Void)?
    public var onChannelTap: ((Int) -> Void)?
    
    let categoryLabel: UILabel = {
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
    
    lazy var categoryCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize.init(width: 130, height: 170)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        cv.showsHorizontalScrollIndicator = false
        cv.register(MainChannelsCategotyCollectionViewCell.self, forCellWithReuseIdentifier: MainChannelsCategotyCollectionViewCell.cellIdentifier)
        cv.backgroundColor = .clear
        return cv
    }()
    
    convenience init(frame: CGRect, category: ChannelCategoryViewModel) {
        self.init(frame: frame)
        
        self.category = category
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        self.backgroundColor = .white
        
        seeAllButton.addTarget(self, action: #selector(onSeeAllBtnTouched(_:)), for: .touchUpInside)
        self.addSubview(seeAllButton)
        seeAllButton.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.right.equalTo(-10)
            make.width.equalTo(60)
            make.height.equalTo(39)
        }
        
        categoryLabel.text = self.category.name
        self.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(16)
            make.right.equalTo(seeAllButton.snp.left)
            make.height.equalTo(41)
        }
        
        self.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(categoryLabel.snp.bottom).inset(-6)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(170)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onSeeAllBtnTouched(_ sender: Any) {
        self.onSeeAll!(self.category.name)
    }
}

extension MainChannelsCategoryCellView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.category.channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryChannel", for: indexPath) as! MainChannelsCategotyCollectionViewCell
        cell.fill(channel: self.category.channels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onChannelTap!(indexPath.item)
    }
}
