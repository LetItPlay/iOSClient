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
import DeepLinkKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deeplinkRouter: DPLDeepLinkRouter = DPLDeepLinkRouter()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AnalyticsEngine.sendEvent(event: .appLoaded)
        
        setupDeepLink()
        setupAppearence()
        migrate()
        
        UserSettings.session = UUID.init().uuidString
		
		self.window = UIWindow.init(frame: UIScreen.main.bounds)

        let languages = UserSettings.languages
        if UserSettings.language.identifier == "none" {
            switch NSLocale.preferredLanguages[0] {
            case "en":
                UserSettings.language = languages[0]
            case "zh-Hans":
                UserSettings.language = languages[1]
            case "ru":
                UserSettings.language = languages[2]
            case "fr":
                UserSettings.language = languages[3]
            default:
                UserSettings.language = languages[0]
            }
		}
        
		self.window?.rootViewController = MainRouter.shared.mainController
		self.window?.makeKeyAndVisible()

		Fabric.with([Crashlytics.self])
		
        return true
    }
    
    func setupDeepLink() {
        self.deeplinkRouter.register("/tracks") { link in
            if let link = link {
                if let channelID = Int(link.queryParameters["channel"] as! String) {
                    if let param = link.queryParameters["track"] as? String,
                        let trackID = Int(param) {
                        MainRouter.shared.show(screen: "channel", params: ["id" : channelID, "trackID" : trackID], present: false)
                        return
                    }
                    MainRouter.shared.show(screen: "channel", params: ["id" : channelID], present: false)
                }
            }
        }
    }

    // MARK: - appearence setup
    func setupAppearence() {
        UITabBar.appearance().tintColor = UIColor.vaActive
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.tintColor = .red
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: AppColor.Element.tomato], for: .normal)
    }
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		try? AVAudioSession.sharedInstance().setActive(true)
	}
    
    //DB
    func migrate() {
        let config = Realm.Configuration(
            schemaVersion: 6,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 4) {
                }
				
				if (oldSchemaVersion < 5) {
					migration.enumerateObjects(ofType: "Station", { (old, new) in
						new?["trackCount"] = 0
					})
				}
				
				if (oldSchemaVersion < 5) {
					(try? Realm.init())?.deleteAll()
				}
		})
        Realm.Configuration.defaultConfiguration = config
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let newUserActivity = userActivity
        newUserActivity.webpageURL = URL(string: (newUserActivity.webpageURL?.absoluteString.replacingOccurrences(of: "/#", with: ""))!)
        self.deeplinkRouter.handle(userActivity, withCompletion: nil)
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        self.deeplinkRouter.handle(url, withCompletion: nil)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        self.deeplinkRouter.handle(url, withCompletion: nil)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
		try? AVAudioSession.sharedInstance().setActive(true)
	}
	
}

