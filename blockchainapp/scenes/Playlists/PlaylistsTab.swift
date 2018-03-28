//
//  PlaylistsTab.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 28.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import Tabman
import Pageboy

class PlaylistsTab: TabmanViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        // configure the bar
        self.bar.items = [Item(title: "My playlist".localized),
                          Item(title: "Recommended".localized)]
        
        self.bar.style = .buttonBar
        self.view.backgroundColor = .white
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.state.selectedColor = .black
            appearance.text.font = AppFont.Title.small
            appearance.indicator.isProgressive = false
            appearance.indicator.color = AppColor.Element.redBlur
        })
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc func search() {
        MainRouter.shared.show(screen: "search", params: [:], present: false)
    }
}

extension PlaylistsTab: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return 2
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        switch index {
        case 0:
            return UserPlaylistBuilder.build(params: nil)
        case 1:
            return PlaylistsBuilder.build(params: nil)
        default:
            return nil//UIViewController()
        }
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
