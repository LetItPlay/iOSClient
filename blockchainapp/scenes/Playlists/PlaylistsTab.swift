//
//  PlaylistsTab.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 27.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import SnapKit

class PlaylistsTab: ButtonBarPagerTabStripViewController {
    
    let _scrollView = UIScrollView()
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = AppColor.Element.redBlur //self?.blueInstagramColor
        }
        
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
//        self.view.addSubview(_scrollView)
//        _scrollView.snp.makeConstraints({ (make) in
//            make.edges.equalToSuperview()
//        })
        
//        self.containerView = _scrollView
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [UserPlaylistBuilder.build(params: nil)!, PlaylistsBuilder.build(params: nil)!]
    }
}
