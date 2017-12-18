//
//  DBHelpers.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 02/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DBManager {
    
    static let shared = DBManager()
    
    func track(byId: Int) -> Track? {
        let realm = try! Realm()
        return realm.object(ofType: Track.self, forPrimaryKey: byId)
    }
    
    func addOrUpdateStation(inRealm: Realm, id: Int, name: String, image: String, subscriptionCount: Int, tags: String?) {
        if let station = inRealm.object(ofType: Station.self, forPrimaryKey: id) {
            _ = updateIfNeeded(property: &station.name, new: name)
            _ = updateIfNeeded(property: &station.image, new: image)
            _ = updateIfNeeded(property: &station.subscriptionCount, new: subscriptionCount)
            _ = updateIfNeeded(property: &station.tagString, new: tags ?? "")
        } else {
            let newStat = Station()
            newStat.id = id
            newStat.name = name
            newStat.image = image
            newStat.subscriptionCount = subscriptionCount
            newStat.tagString = tags ?? ""
            
            inRealm.add(newStat)
        }
    }
    
    func addOrUpdateTrack(inRealm: Realm, id: Int, station: Int, audiofile: Audiofile?, name: String, url: String, description: String, image: String, likeCount: Int, reportCount: Int, listenCount: Int, tags: String?, publishDate: String) {
        if let track = inRealm.object(ofType: Track.self, forPrimaryKey: id) {
            var changeCounter = 0
            changeCounter += updateIfNeeded(property: &track.station, new: station)
            changeCounter += updateIfNeeded(property: &track.name, new: name)
            changeCounter += updateIfNeeded(property: &track.desc, new: description)
            changeCounter += updateIfNeeded(property: &track.image, new: image)
            changeCounter += updateIfNeeded(property: &track.likeCount, new: likeCount)
            changeCounter += updateIfNeeded(property: &track.reportCount, new: reportCount)
            changeCounter += updateIfNeeded(property: &track.listenCount, new: listenCount)
            changeCounter += updateIfNeeded(property: &track.tagString, new: tags ?? "")
            
            let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			
			if publishDate == "" {
				print("fcuk")
			}
			
            changeCounter += updateIfNeeded(property: &track.publishedAt, new: formatter.date(from: publishDate) ?? Date().addingTimeInterval(-60*60*24*30))
            
            if track.audiofile?.file != audiofile?.file {
                track.audiofile = audiofile
                changeCounter += 1
            }
			track.audiofile = audiofile
            
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
            newTrack.listenCount = listenCount
            newTrack.tagString   = tags ?? ""
            
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

extension DBManager {
    public func track(fromJSON: JSON, realm: Realm) {
        if let idInt = fromJSON["id"].int {
            var audioFile: Audiofile? = nil
            if let file = fromJSON["audio_file"]["file"].string {
                audioFile = Audiofile()
                audioFile?.file = file
                audioFile?.lengthSeconds = fromJSON["audio_file"]["length_seconds"].int64 ?? 0
                audioFile?.sizeBytes = fromJSON["audio_file"]["size_bytes"].int64 ?? 0
            }
            
            addOrUpdateTrack(inRealm: realm,
                             id: idInt,
                             station: fromJSON["station"].int ?? 0,
                             audiofile: audioFile,
                             name: fromJSON["name"].string ?? "",
                             url: fromJSON["url"].string ?? "",
                             description: fromJSON["description"].string ?? "",
                             image: fromJSON["image"].string ?? "",
                             likeCount: fromJSON["like_count"].int ?? 0,
                             reportCount: fromJSON["report_count"].int ?? 0,
                             listenCount: fromJSON["listen_count"].int ?? 0,
                             tags: fromJSON["tags"].string,
                             publishDate: fromJSON["published_at"].string ?? "")
        }
    }
}
