//
//  Managers.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyAudioManager

typealias ChannelsLoaderSuccess = ([Station]) -> Void
typealias TracksLoaderSuccess = ([Track]) -> Void
typealias ChannelsLoaderFail = (Error?) -> Void

class AppManager {
    static let shared = AppManager()
    
    public let audioManager = AudioManager()
    public lazy var  audioPlayer  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "player") as? PlayerViewController
    
    private let tabDelegate = MainTabBarDelegate()
    public var rootTabBarController: MainTabViewController? {
        didSet {
            if rootTabBarController != nil {
                rootTabBarController?.delegate = tabDelegate
            }
        }
    }
    
    init() {
        audioManager.isPlayingSpeakerMode = true
    }
}

class DownloadManager {
    
    enum urlServices: String {
        case audiofiles = "http://176.31.100.18:8182/audiofiles/"
        case stations = "http://176.31.100.18:8182/stations/"
        case tracks = "http://176.31.100.18:8182/tracks/"
        case tracksForStations = "http://176.31.100.18:8182/api/tracks/stations/"
        case subForStations = "http://176.31.100.18:8182/stations/%d/counts/"
        case forTracks = "http://176.31.100.18:8182/tracks/%d/counts/"
    }
    
    static let shared = DownloadManager()
    
    func requestChannels(success: @escaping ChannelsLoaderSuccess, fail: @escaping ChannelsLoaderFail) {
        if let str = urlServices.stations.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard error == nil else {
                    fail(error)
                    return
                }
                
                guard let data = data else {
                    fail(error)
                    return
                }
                
                let json = JSON(data: data)
                var result = [Station]()
                for jStation in json.array ?? [] {
                    if let idInt = jStation["id"].int {
                        let station = Station(id: idInt,
                                              name: jStation["name"].string ?? "",
                                              image: jStation["image"].string ?? "",
                                              subscriptionCount: jStation["subscription_count"].int ?? 0)
                        result.append(station)
                    } else {
                        print("ERROR: no id in \(jStation)")
                    }
                }
                
                success(result)
            })
            task.resume()
        }
    }
    
    func requestTracks(success: @escaping TracksLoaderSuccess, fail: @escaping ChannelsLoaderFail) {
        if let str = urlServices.tracksForStations.rawValue.appending(SubscribeManager.shared.requestString()).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard error == nil else {
                    fail(error)
                    return
                }
                
                guard let data = data else {
                    fail(error)
                    return
                }
                
                let json = JSON(data: data)
                var result = [Track]()
                for jTrack in json.array ?? [] {
                    if let idInt = jTrack["id"].int {
                        let file = Audiofile(file: jTrack["audio_file"]["file"].string ?? "",
                                             lengthSeconds: jTrack["audio_file"]["length_seconds"].int64 ?? 0,
                                             sizeBytes: jTrack["audio_file"]["size_bytes"].int64 ?? 0)
                        
                        let t = Track(id: idInt,
                                      station: jTrack["station"].int ?? 0,
                                      audiofile: file,
                                      name: jTrack["name"].string ?? "",
                                      url: jTrack["url"].string ?? "",
                                      description: jTrack["description"].string ?? "",
                                      image: jTrack["image"].string ?? "",
                                      likeCount: jTrack["like_count"].int ?? 0,
                                      reportCount: jTrack["report_count"].int ?? 0)
                        result.append(t)
                    }
                }
                
                success(result)
            })
            task.resume()
        }
    }
    
    func subscribe(onStation: Int, withCount: Int = 1) {
        if let str = String(format: urlServices.subForStations.rawValue, onStation).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["subscription_count": withCount], options: .prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard error == nil else {
                    
                    return
                }
                
                guard let _ = data else {
                    
                    return
                }
                
                
            })
            task.resume()
        }
    }
    
    func track(id: Int, report: Int = 0, like: Int = 0) {
        if let str = String(format: urlServices.forTracks.rawValue, id).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var elements: [String: Int] = [:]
            elements["report_count"] = report
            elements["like_count"]   = like
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard error == nil else {
                    
                    return
                }
                
                guard let _ = data else {
                    
                    return
                }
                
                
            })
            task.resume()
        }
    }
    
}

class SubscribeManager {
    
    public enum NotificationName: String {
        
        case added   = "SubscribeManager_recivedNewStation"
        case deleted = "SubscribeManager_deletedStation"
        
        public var notification: Notification.Name  {
            return Notification.Name(rawValue: self.rawValue)
        }
        
    }
    
    init() {
        stations = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
    }
    
    static let shared = SubscribeManager()
    
    private var stations = [Int]()
    
    public func requestString() -> String {
        return stations.map{ "\($0)" }.joined(separator: ",")
    }
    
    public func addOrDelete(station: Int) {
        if hasStation(id: station) {
            removeStation(id: station)
        } else {
            addStation(id: station)
        }
        
        UserDefaults.standard.set(stations, forKey: "array_sub")
    }
    
    public func hasStation(id: Int) -> Bool {
        return stations.contains(id)
    }
    
    private func addStation(id: Int) {
        objc_sync_enter(stations)
        stations.append(id)
        objc_sync_exit(stations)
        
        debugPrint("user subscribed on \(id)")
        NotificationCenter.default.post(name: NotificationName.added.notification,
                                        object: nil,
                                        userInfo: ["id": id])
        
        DownloadManager.shared.subscribe(onStation: id)
    }
    
    private func removeStation(id: Int) {
        objc_sync_enter(stations)
        if let index = stations.index(of: id) {
            stations.remove(at: index)
        }
        objc_sync_exit(stations)
        
        debugPrint("user unsubscribed on \(id)")
        NotificationCenter.default.post(name: NotificationName.deleted.notification,
                                        object: nil,
                                        userInfo: ["id": id])
        
        DownloadManager.shared.subscribe(onStation: id, withCount: -1)
    }
    
}

class LikeManager {
    static let shared = LikeManager()
    
    private var stations = [Int]()
    
    init() {
        stations = (UserDefaults.standard.array(forKey: "array_like") as? [Int]) ?? []
    }
    
    public func addOrDelete(id: Int) {
        if hasObject(id: id) {
            dislike(id: id)
        } else {
            like(id: id)
        }
        
        UserDefaults.standard.set(stations, forKey: "array_like")
    }
    
    public func hasObject(id: Int) -> Bool {
        return stations.contains(id)
    }
    
    private func like(id: Int) {
        objc_sync_enter(stations)
        stations.append(id)
        objc_sync_exit(stations)
        
        debugPrint("user like on \(id)")
        
        DownloadManager.shared.track(id: id, like: 1)
    }
    
    private func dislike(id: Int) {
        objc_sync_enter(stations)
        if let index = stations.index(of: id) {
            stations.remove(at: index)
        }
        objc_sync_exit(stations)
        
        debugPrint("user dislike on \(id)")
        
        DownloadManager.shared.track(id: id, like: -1)
    }
}

