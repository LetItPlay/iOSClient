//
//  FeedBuilder.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 05/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class FeedBuilder: Builder {
	static func build() -> UIViewController {
		let vc = FeedViewController(type: .feed)
		return vc
	}
}

class PopularBuilder: Builder {
	static func build() -> UIViewController {
		let vc = FeedViewController(type: .popular)
		return vc
	}
}
