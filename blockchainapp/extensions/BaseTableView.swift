//
//  BaseTableView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 18.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.backgroundColor = .white
        self.contentInset.bottom = 72
        self.separatorStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
