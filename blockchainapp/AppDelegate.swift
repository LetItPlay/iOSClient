//
//  AppDelegate.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 28/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
        setupAppearence()
        migrate()
		
		
		self.window = UIWindow.init(frame: UIScreen.main.bounds)

		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: AppColor.Element.tomato], for: .normal)

		var vc: UIViewController!
		if UserSettings.language == .none {
			vc = SettingsViewController()
		} else {
			vc = MainTabViewController()
		}
		self.window?.rootViewController = vc
		self.window?.makeKeyAndVisible()

		Fabric.with([Crashlytics.self])
        return true
    }

    // MARK: - appearence setup
    func setupAppearence() {
        UITabBar.appearance().tintColor = UIColor.vaActive
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .highlighted)
        BarButtonItemAppearance.tintColor = .red
    }
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		try? AVAudioSession.sharedInstance().setActive(true)
	}
    //DB
    func migrate() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 6,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 4) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
				
				if (oldSchemaVersion < 5) {
					migration.enumerateObjects(ofType: "Station", { (old, new) in
						new?["trackCount"] = 0
					})
				}
				
				if (oldSchemaVersion < 5) {
//					migration.enumerateObjects(ofType: "Track", { (old, new) in
//						if let tagString = old?["tagString"] as? String, let newObj = new {
//							let tags = tagString.components(separatedBy: ",").map({ (tag) -> Tag in
//								let rlmTag = Tag.init()
//								rlmTag.value = tag
//								return rlmTag
//							})
//							let list = List<Tag>.init()
//							tags.forEach({ (tag) in
//								list.append(tag)
//							})
//							newObj["tags"] = list
//						}
//						if let length = (old?["audiofile"] as? MigrationObject)?["lengthSeconds"] as? Int64,
//							let cover = (old?["audiofile"] as? MigrationObject)?["lengthSeconds"] as? String,
//							let url = (old?["audiofile"]as? MigrationObject)?["file"] as? String {
//							new?["length"] = length
//							new?["coverURL"] = cover
//							new?["url"] = url
//						} else {
//							new?["length"] = 0
//							new?["coverURL"] = ""
//							new?["url"] = ""
//						}
//					})
//					migration.enumerateObjects(ofType: "Station", { (old, new) in
//						if let tagString = old?["tagString"] as? String, let newObj = new {
//							let tags = tagString.components(separatedBy: ",").map({ (tag) -> Tag in
//								let rlmTag = Tag.init()
//								rlmTag.value = tag
//								return rlmTag
//							})
//							let list = List<Tag>.init()
//							tags.forEach({ (tag) in
//								list.append(tag)
//							})
//							newObj["tags"] = list
//							new?["sourceURL"] = ""
//						}
//					})
					(try? Realm.init())?.deleteAll()
				}
		})
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }

	func applicationDidBecomeActive(_ application: UIApplication) {
		try? AVAudioSession.sharedInstance().setActive(true)
	}
	
}

