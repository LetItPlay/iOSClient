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
    case longTap(to: LongTap)
    case player(to: Player)
    
    enum SearchEvent {
        case search
        case channelTapped
        case trackTapped
    }
    
    enum TrendEvent {
        case cardTapped
        case channelTapped
        case seeAll
    }
    
    enum Swipe: String {
        case left = "left"
        case right = "right"
    }
    
    enum LongTap {
        case showInfo
        case hideInfo
    }
    
    enum Player: String {
        case open = "open"
        case close = "close"
    }
    
    var name: String {
        switch self {
        case .tabSelected:
            return "tabSelected"
        case .searchEvent(event: .search):
            return "search"
        case .searchEvent(event: .channelTapped):
            return "channelTapped"
        case .searchEvent(event: .trackTapped):
            return "trackTapped"
        case .feedCardSelected:
            return "cardSelected"
        case .trendEvent(event: .cardTapped):
            return "cardTapped"
        case .trendEvent(event: .channelTapped):
            return "channelTapped"
        case .trendEvent(event: .seeAll):
            return "seeAll"
        case .swipe:
            return "swipe"
        case .longTap(to: .showInfo):
            return "longTap"
        case .longTap(to: .hideInfo):
            return "longTap"
        case .player:
            return "player"
        }
    }
    
    var metadata: [String : String] {
        switch self {
        case .tabSelected(let controller):
            return ["controller" : controller]
        case .searchEvent(event: .search):
            return ["search" : ""]
        case .searchEvent(event: .channelTapped):
            return ["channelTapped" : ""]
        case .searchEvent(event: .trackTapped):
            return ["trackTapped" : ""]
        case .feedCardSelected:
            return ["cardSelected" : ""]
        case .trendEvent(event: .cardTapped):
            return ["cardTapped" : ""]
        case .trendEvent(event: .channelTapped):
            return ["channelTapped" : ""]
        case .trendEvent(event: .seeAll):
            return ["seeAll" : ""]
        case .swipe(let direction):
            return ["direction" : direction.rawValue]
        case .longTap(to: .showInfo):
            return ["info" : "show"]
        case .longTap(to: .hideInfo):
            return ["info" : "hide"]
        case .player(let move):
            return ["move" : move.rawValue]
            
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
