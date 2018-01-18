//
//  Extensions.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 18/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

extension IndexPath {
	static let invalid: IndexPath = IndexPath.init(row: -1, section: -1)
}

extension Array where Element == [AudioTrack]{
	subscript(indexPath: IndexPath) -> AudioTrack {
		return self[indexPath.section][indexPath.item]
	}
}
