//
//  PlaylistsTab1.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 28.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import Tabman
import Pageboy

class PlaylistsTab1: TabmanViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        // configure the bar
        self.bar.items = [Item(title: "User Playlst"),
                          Item(title: "Playlists")]
        
        self.bar.style = .buttonBar
        self.view.backgroundColor = .white
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            // customize appearance here
            appearance.state.selectedColor = .black
            appearance.text.font = AppFont.Title.mid
            appearance.indicator.isProgressive = false
            appearance.indicator.color = AppColor.Element.redBlur
        })
    }
}

extension PlaylistsTab1: PageboyViewControllerDataSource {
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
