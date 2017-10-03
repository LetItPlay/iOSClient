//
//  DBHelpers.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 02/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager {
    
    static let shared = DBManager()
    
    func track(byId: Int) -> Track? {
        let realm = try! Realm()
        return realm.object(ofType: Track.self, forPrimaryKey: byId)
    }
    
    func addOrUpdateStation(inRealm: Realm, id: Int, name: String, image: String, subscriptionCount: Int) {
        if let station = inRealm.object(ofType: Station.self, forPrimaryKey: id) {
            _ = updateIfNeeded(property: &station.name, new: name)
            _ = updateIfNeeded(property: &station.image, new: image)
            _ = updateIfNeeded(property: &station.subscriptionCount, new: subscriptionCount)
        } else {
            let newStat = Station()
            newStat.id = id
            newStat.name = name
            newStat.image = image
            newStat.subscriptionCount = subscriptionCount
            
            inRealm.add(newStat)
        }
        
    }
    
    func addOrUpdateTrack(inRealm: Realm, id: Int, station: Int, audiofile: Audiofile?, name: String, url: String, description: String, image: String, likeCount: Int, reportCount: Int) {
        if let track = inRealm.object(ofType: Track.self, forPrimaryKey: id) {
            var changeCounter = 0
            changeCounter += updateIfNeeded(property: &track.station, new: station)
            changeCounter += updateIfNeeded(property: &track.name, new: name)
            changeCounter += updateIfNeeded(property: &track.desc, new: description)
            changeCounter += updateIfNeeded(property: &track.image, new: image)
            changeCounter += updateIfNeeded(property: &track.likeCount, new: likeCount)
            changeCounter += updateIfNeeded(property: &track.reportCount, new: reportCount)
            
            if track.audiofile?.file != audiofile?.file {
                track.audiofile = audiofile
                changeCounter += 1
            }
            
            debugPrint("track \(id) counter=\(changeCounter)")
        } else {
            let newTrack = Track()
            newTrack.id = id
            newTrack.station   = station
            newTrack.audiofile = audiofile
            newTrack.name = name
            newTrack.url  = url
            newTrack.desc = description
            newTrack.image = image
            newTrack.likeCount = likeCount
            newTrack.reportCount = reportCount
            
            inRealm.add(newTrack)
        }
        
    }
    
    private func updateIfNeeded<T: Equatable>(property: inout T, new: T) -> Int {
        if property != new {
            property = new
            
            return 1
        }
        
        return 0
    }
    
}
