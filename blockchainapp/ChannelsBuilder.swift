//
//  ChannelsBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

protocol Builder {
	static func build() -> UIViewController
}

class ChannelsBuilder: Builder {
	static func build() -> UIViewController {
		let vc = ChannelsViewController()
		return vc
	}
}
