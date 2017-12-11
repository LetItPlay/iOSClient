//
//  RealmExtension.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 11/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import RealmSwift

protocol DetachableObject: class {
	
	func detached() -> Self
	
}

extension List where Element: DetachableObject {
	
	func detached() -> List<Element> {
		let result = List<Element>()
		forEach {
			result.append($0.detached())
		}
		return result
	}
	
}

extension Object: DetachableObject {
	
	func detached() -> Self {
		let detached = type(of: self).init()
		for property in objectSchema.properties {
			guard let value = value(forKey: property.name) else { continue }
			if let detachable = value as? DetachableObject {
				detached.setValue(detachable.detached(), forKey: property.name)
			} else {
				detached.setValue(value, forKey: property.name)
			}
		}
		return detached
	}
	
}
