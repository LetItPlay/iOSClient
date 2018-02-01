//
//  Analytics.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 31.01.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//


import CloudKit

enum AnalyticsEvent {
    case tabSelected(controller: String)
    case searchEvent(event: SearchEvent)
    case feedCardSelected
    case trendEvent(event: TrendEvent)
    case swipe(direction: Swipe)
    case tapAfterSwipe(direction: Swipe)
    case longTap(to: LongTap)
    case player(to: Player)
    case profileEvent(on: ProfileEvent)
    case trackInPlaylistTapped
    case channelEvent(event: ChannelEvent)
    
    enum ChannelEvent: String {
        case tegTapped = "tegTapped"
        case cardTapped = "cardTapped"
    }
    
    enum ProfileEvent: String {
        case avatar = "avatarTapped"
        case name = "nameTapped"
        case like = "likeTapped"
    }
    
    enum SearchEvent: String {
        case search = "search"
        case channelTapped = "channelTapped"
        case trackTapped = "trackTapped"
        case playlistTapped = "playlistTapped"
    }
    
    enum TrendEvent: String {
        case cardTapped = "cardTapped"
        case channelTapped = "channelTapped"
        case seeAll = "seeAllTapped"
        case channelSeeAll = "channelSeeAllTapped"
    }
    
    enum Swipe: String {
        case left = "left"
        case right = "right"
    }
    
    enum LongTap: String {
        case showInfo = "show"
        case hideInfo = "hide"
    }
    
    enum Player: String {
        case open = "open"
        case close = "close"
    }
    
    var name: String {
        switch self {
        case .tabSelected:
            return "tab"
        case .searchEvent:
            return "searchTab"
        case .feedCardSelected:
            return "feedTab"
        case .trendEvent:
            return "trendTab"
        case .swipe:
            return "swipe"
        case .tapAfterSwipe:
            return "tapAfterSwipe"
        case .longTap:
            return "longTap"
        case .player:
            return "playerTab"
        case .profileEvent:
            return "profileEvent"
        case .trackInPlaylistTapped:
            return "playlist"
        case .channelEvent:
            return "channelTab"
        }
    }
    
    var metadata: [String : String] {
        switch self {
        case .tabSelected(let controller):
            return ["controllerSelected" : controller]
        case .searchEvent(let searchEvent):
            return ["action" : searchEvent.rawValue]
        case .feedCardSelected:
            return ["cardSelected" : ""]
        case .trendEvent(let event):
            return ["event" : event.rawValue]
        case .swipe(let direction):
            return ["direction" : direction.rawValue]
        case .tapAfterSwipe(let direction):
            return ["side" : direction.rawValue]
        case .longTap(let event):
            return ["info" : event.rawValue]
        case .player(let move):
            return ["moveTo" : move.rawValue]
        case .profileEvent(let event):
            return ["event" : event.rawValue]
        case .trackInPlaylistTapped:
            return ["event" : "trackTapped"]
        case .channelEvent(let event):
            return ["event" : event.rawValue]
        }
    }
}
    

protocol AnalyticsEngine: class {
    func sendAnalyticsEvent(named name: String, metadata: [String : String])
}

class AnalyticsManager {
    private let engine: AnalyticsEngine
    
    init(engine: AnalyticsEngine) {
        self.engine = engine
    }
    
    func log(_ event: AnalyticsEvent) {
        engine.sendAnalyticsEvent(named: event.name, metadata: event.metadata)
    }
}

class CloudKitAnalyticsEngine: AnalyticsEngine {
    private let database: CKDatabase
    
    init(database: CKDatabase = CKContainer.default().publicCloudDatabase) {
        self.database = database
    }
    
    func sendAnalyticsEvent(named name: String, metadata: [String : String]) {
        let record = CKRecord(recordType: "AnalyticsEvent.\(name)")
        
        for (key, value) in metadata {
            record[key] = value as NSString
        }
        
        database.save(record) { _, _ in
            // We treat this as a fire-and-forget type operation
        }
    }
}
