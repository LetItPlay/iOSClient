//
//  Managers.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyJSON
 
import RealmSwift

typealias ChannelsLoaderSuccess = ([Station]) -> Void
typealias TracksLoaderSuccess = ([Track]) -> Void
typealias ChannelsLoaderFail = (Error?) -> Void

class AppManager {
    static let shared = AppManager()
    
//    public lazy var  audioPlayer  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "audiocore") as? AudioCoreViewController
	
    private let tabDelegate = MainTabBarDelegate()
    public var rootTabBarController: MainTabViewController? {
        didSet {
            if rootTabBarController != nil {
                rootTabBarController?.delegate = tabDelegate
            }
        }
    }
    
    init() {
    }
}

class DownloadManager {
    
    enum urlServices: String {
        case audiofiles = "https://manage.letitplay.io/api/audiofiles/"
        case stations = "https://manage.letitplay.io/api/stations/"
        case tracks = "https://manage.letitplay.io/api/tracks/"
        case tracksForStations = "https://manage.letitplay.io/api/tracks/stations/"
        case subForStations = "https://manage.letitplay.io/api/stations/%d/counts/"
        case forTracks = "https://manage.letitplay.io/api/tracks/%d/counts/"
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
                
                do {
					let json  = try JSON(data: data)
					let realm = try Realm()
					try realm.write {
						realm.delete(realm.objects(Station.self))
					}
                    try realm.write {
                        for jStation in json.array ?? [] {
                            if let idInt = jStation["id"].int {
                                DBManager.shared.addOrUpdateStation(inRealm: realm,
                                                                    id: idInt,
                                                                    name: jStation["name"].string ?? "",
                                                                    image: jStation["image"].string ?? "",
                                                                    subscriptionCount: jStation["subscription_count"].int ?? 0,
                                                                    tags: jStation["tags"].string,
																	lang: jStation["lang"].string ?? "ru")
                            } else {
                                print("ERROR: no id in \(jStation)")
                            }
                        }
                    }
                } catch(let error) {
                    print(error)
                }
//                success(result)
            })
            task.resume()
        }
    }
    
	func requestTracks(all: Bool = false, success: @escaping TracksLoaderSuccess, fail: @escaping ChannelsLoaderFail) {
		let path = all ? urlServices.tracks.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) :
	urlServices.tracksForStations.rawValue.appending(SubscribeManager.shared.requestString()).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		if let path = path, let url = URL(string: path) {
            
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
                
                do {
					let json  = try JSON(data: data)
					let realm = try Realm()
                    try realm.write {
                        for jTrack in json.array ?? [] {
							DBManager.shared.track(fromJSON: jTrack, realm: realm)
                        }
                    }
                } catch(let error) {
                    print(error)
                }
                
//                success(result)
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
    
    func track(id: Int, report: Int = 0, like: Int = 0, listen: Int = 0) {
        if let str = String(format: urlServices.forTracks.rawValue, id).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var elements: [String: Int] = [:]
            elements["report_count"] = report
            elements["like_count"]   = like
            elements["listen_count"] = listen
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard error == nil else { return }
                guard let data = data else { return }

                do {
					let json  = try JSON(data: data)
					let realm = try Realm()
                    try realm.write {
                        DBManager.shared.track(fromJSON: json, realm: realm)
                    }
                } catch(let error) {
                    print(error)
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
        listenedTracks = (UserDefaults.standard.array(forKey: "listen_tracks") as? [Int]) ?? []
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(audioManagerStartPlaying(_:)),
//                                               name: AudioManagerNotificationName.startPlaying.notification,
//                                               object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func audioManagerStartPlaying(_ notification: Notification) {
//        DispatchQueue.global().async { [unowned self] in
//            if let id = AppManager.shared.audioManager.currentItemId,
//                let idstring = id.split(separator: "_").last,
//                let trackId = Int(idstring) {
//                if !self.listenedTracks.contains(trackId) {
//                    objc_sync_enter(self.listenedTracks)
//                    self.listenedTracks.append(trackId)
//                    UserDefaults.standard.set(self.listenedTracks, forKey: "listen_tracks")
//                    objc_sync_exit(self.listenedTracks)
//                    DownloadManager.shared.track(id: trackId, listen: 1)
//                }
//            }
//        }
    }

    
    static let shared = SubscribeManager()
    
	private (set) internal var stations = [Int]()
    private var listenedTracks = [Int]()
    
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
        
//        let realm = try! Realm()
//        try? realm.write {
//            realm.delete(realm.objects(Track.self).filter("station = %@", id))
//        }
		
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

