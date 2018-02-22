//
//  NewFeedLabel.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 20/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class NewFeedLabel: UIView {
	
	let label: UILabel = UILabel()
	var bluredViews: [UIView] = []
	
	init() {
		super.init(frame: CGRect.zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}
