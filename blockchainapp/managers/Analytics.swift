//
//  Analytics.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 31.01.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//


import CloudKit
import Crashlytics

enum AnalyticsEvent: Int {
    case appLoaded = 51
    case tabSelected = 52
    case langChanged = 53
    
    case play = 101
    case pause = 102
    case playlistSelected = 303
}

var eventDict: [String: Any] = ["v": UserSettings.version,
                                  "pt": 2,
                                  "pst": 21,
                                  "sid": UserSettings.session,
                                  "uid": UserSettings.userIdentifier,
                                  "lang": UserSettings.language.currentLanguage]

class AnalyticsEngine {
    class func sendEvent(event: AnalyticsEvent) {
        eventDict["et"] = event.rawValue
        RequestManager.shared.sendAnalytic(event: eventDict)
    }
}

