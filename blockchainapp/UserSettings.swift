//
//  UserSettings.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 19/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum Language: String {
	case en = "en", ru = "ru", none = "suicide silence"
}

class UserSettings {
	static var language: Language {
		get {
			let def = UserDefaults.standard
			var res: Language
			if let langStr = def.value(forKey: "lang") as? String, let lang = Language.init(rawValue: langStr) {
				res = lang
			} else {
				def.setValue(Language.none.rawValue, forKey: "lang")
				def.synchronize()
				res = .none
			}
			return res
		}
		set(newLang) {
			let def = UserDefaults.standard
			def.setValue(newLang.rawValue, forKey: "lang")
			def.synchronize()
		}
	}
}
