//
//  UserSettings.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 19/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

enum Language: String {
	case en = "en", ru = "ru", fr = "fr", none = "suicide silence"
}

class UserSettings {
    static var token: String {
        get { return token }
        set {
            token = newValue
        }
    }
    
    static var userIdentifier: String {
        get {
            let def = UserDefaults.standard
            
            if let token = def.value(forKey: "token") as? String {
                return token
            }
            else {
                let newToken = UUID.init().uuidString
                let def = UserDefaults.standard
                def.setValue(newToken, forKey: "token")
                def.synchronize()
                return newToken
            }
        }
    }
    
    static var session: String {
        get {
            let def = UserDefaults.standard
            var res: String = ""
            if let token = def.value(forKey: "session") as? String {
                res = token
            }
            
            return res
        }
        set(newSession) {
            let def = UserDefaults.standard
            def.setValue(newSession, forKey: "session")
            def.synchronize()
        }
    }
    
    static var name: String {
        get {
            let def = UserDefaults.standard
            var res: String
            if let str = def.value(forKey: "name") as? String {
                res = str
            } else {
                def.setValue("name", forKey: "name")
                def.synchronize()
                res = "name"
            }
            return res
        }
        set(newName) {
            if newName != ""
            {
                let def = UserDefaults.standard
                def.setValue(newName, forKey: "name")
                def.synchronize()
            }
        }
    }
    
    static var image: Data {
        get {
            let def = UserDefaults.standard
            var res: Data
            if let data = def.value(forKey: "image") as? Data {
                res = data
            } else {
                res = UIImagePNGRepresentation(UIImage.init(named: "placeholder")!)!
                def.set(res, forKey: "image")
                def.synchronize()
            }
            return res
        }
        
        set(newImage) {
            let def = UserDefaults.standard
            def.setValue(newImage, forKey: "image")
            def.synchronize()
        }
    }
    
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
