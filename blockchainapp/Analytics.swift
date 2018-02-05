//
//  Analytics.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 31.01.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//


import CloudKit
import Crashlytics

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
    case channelTegTapped

    
    enum ProfileEvent: String {
        case avatar = "avatarTapped"
        case name = "nameTapped"
        case like = "likeTapped"
    }
    
    enum SearchEvent {
        case search(text: String)
        case channelTapped
        case trackTapped
        case playlistTapped
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
            return "Tab selected"
        case .searchEvent:
            return "Search Tab"
        case .feedCardSelected:
            return "Feed Tab"
        case .trendEvent:
            return "Trend Tab"
        case .swipe:
            return "swipe"
        case .tapAfterSwipe:
            return "Tap After Swipe"
        case .longTap:
            return "Long Tap"
        case .player:
            return "Player"
        case .profileEvent:
            return "Profile Tab"
        case .trackInPlaylistTapped:
            return "Playlist"
        case .channelTegTapped:
            return "Cannel Tab"
        }
    }
    
    var metadata: [String : String] {
        switch self {
        case .tabSelected(let controller):
            return ["controllerSelected" : controller]
        case .searchEvent(event: .search(let text)):
            return ["searching" : text]
        case .searchEvent(event: .channelTapped):
            return ["event" : "channelTapped"]
        case .searchEvent(event: .trackTapped):
            return ["event" : "trackTapped"]
        case .searchEvent(event: .playlistTapped):
            return ["event" : "playlistTapped"]
        case .feedCardSelected:
            return ["cardSelected" : "cardSelected"]
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
        case .channelTegTapped:
            return ["event" :  "tegTapped"]
        }
    }
}

class AnalyticsEngine {
    class func sendEvent(event: AnalyticsEvent) {
        Answers.logCustomEvent(withName: event.name, customAttributes: event.metadata)
    }
}

