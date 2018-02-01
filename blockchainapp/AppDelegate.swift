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
    }
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		try? AVAudioSession.sharedInstance().setActive(true)
	}
    //DB
    func migrate() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 5,
            
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
				
		})
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }

	func applicationDidBecomeActive(_ application: UIApplication) {
		try? AVAudioSession.sharedInstance().setActive(true)
	}
	
}

