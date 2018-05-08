//
//  UserSettings.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 19/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class UserSettings {
    
    public static let languages: [Language] = [Language(identifier: "en", name: "English", currentLanguage: "Language: English",
                                               switchTo: "Switch to English 🇬🇧"),
                                               Language(identifier: "zh", name: "Chinese", currentLanguage: "Language: Chinese",
                                               switchTo: "Change to Chinese 🇨🇳"),
                                               Language(identifier: "ru", name: "Русский", currentLanguage: "Язык: Русский",
                                               switchTo: "Поменять на Русский 🇷🇺"),
                                               Language(identifier: "fr", name: "Français", currentLanguage: "Langue: Français",
                                               switchTo: "Changer en Français 🇫🇷")]
    
    static var token: String = ""
    
    static let version: String = {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }()
    
    static var jwt: String? {
        get {
            let def = UserDefaults.standard
            
            if let jwt = def.value(forKey: "jwt") as? String {
                return jwt
            } else {
                return nil
            }
        }
        
        set(newJWT) {
            let def = UserDefaults.standard
            def.setValue(newJWT, forKey: "jwt")
            def.synchronize()
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
            if let langStr = def.value(forKey: "lang") as? String, let lang = languages.filter({$0.identifier == langStr}).first {
				res = lang
			} else {
                res = Language(identifier: "none", name: "", currentLanguage: "", switchTo: "")
				def.setValue(res.identifier, forKey: "lang")
				def.synchronize()
			}
			return res
		}
		set(newLang) {
			let def = UserDefaults.standard
			def.setValue(newLang.identifier, forKey: "lang")
			def.synchronize()
		}
	}
}
