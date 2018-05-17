//
//  MainModels.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import RxSwift
import Action

class Tag: RealmString {
	
}

protocol LIPModel {
	var id: Int {get}
	var name: String {get}
	var image: URL? {get}
	var lang: String {get}
	var tags: [String] {get}
}
