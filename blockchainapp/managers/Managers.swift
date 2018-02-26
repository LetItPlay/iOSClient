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

import RxSwift
import Action

typealias ChannelsLoaderSuccess = ([ChannelObject]) -> Void
typealias TracksLoaderSuccess = ([TrackObject]) -> Void
typealias ChannelsLoaderFail = (Error?) -> Void

class AppManager {
    static let shared = AppManager()
    
//    public lazy var  audioPlayer  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "audiocore") as? AudioCoreViewController
	
    public var rootTabBarController: MainTabViewController? {
        didSet {
            if rootTabBarController != nil {
            }
        }
    }
    
    init() {
    }
}

class DownloadManager {
    
    enum urlServices: String {
        case audiofiles = "https://manage.letitplay.io/api/audiofiles/"
        case channels = "https://api.letitplay.io/stations"
        case tracks = "https://api.letitplay.io/tracks"
        case tracksForChannels = "https://api.letitplay.io/tracks/stations/"
        case subForChannels = "https://manage.letitplay.io/api/stations/%d/counts/"
        case forTracks = "https://manage.letitplay.io/api/tracks/%d/counts/"
    }
    
    static let shared = DownloadManager()
	
	func channelsSignal() -> Observable<[ChannelObject]> {
		return Observable<[ChannelObject]>.create { (observer) -> Disposable in
			
			if let str = urlServices.channels.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
				let url = URL(string: str) {
				
				let request = URLRequest(url: url)
				let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
					
					guard error == nil else {
						observer.onError(error!)
						return
					}
					
					guard let data = data else {
						observer.onError(NSError.init(domain: "", code: 42, userInfo: nil))
						return
					}
					
					do {
						let json  = try JSON(data: data)
						if let array = json.array {
							let channels = array.map({ ChannelObject.init(json: $0) }).filter({$0 != nil}).map({$0!})
							observer.onNext(channels)
							let realm = try Realm()
							try realm.write {
								realm.delete(realm.objects(ChannelObject.self))
								realm.add(channels, update: true)
//								for jStation in json.array ?? [] {
//									if let idInt = jStation["Id"].int {
//										DBManager.shared.addOrUpdateStation(inRealm: realm,
//																			id: idInt,
//																			name: jStation["Name"].string ?? "",
//																			image: jStation["ImageURL"].string ?? "",
//																			subscriptionCount: jStation["SubscriptionCount"].int ?? 0,
//																			tags: jStation["Tags"].array?.map({$0.string}),
//																			lang: jStation["Lang"].string ?? "ru")
//									} else {
//										print("ERROR: no id in \(jStation)")
//									}
//								}
							}
						}
					} catch(let error) {
						print(error)
					}
					observer.onCompleted()
				})
				task.resume()
			} else {
				observer.onError(NSError.init(domain: "", code: 42, userInfo: nil))
			}
			
			return Disposables.create {
				print("Channels sginal disposed")
			}
		}
	}
	
    func requestChannels(success: @escaping ChannelsLoaderSuccess, fail: @escaping ChannelsLoaderFail) {
        if let str = urlServices.channels.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
						realm.delete(realm.objects(ChannelObject.self))
                        for jChannel in json.array ?? [] {
                            if let idInt = jChannel["Id"].int {
                                DBManager.shared.addOrUpdateChannel(inRealm: realm,
                                                                    id: idInt,
                                                                    name: jChannel["Name"].string ?? "",
                                                                    image: jChannel["ImageURL"].string ?? "",
                                                                    subscriptionCount: jChannel["SubscriptionCount"].int ?? 0,
                                                                    tags: jChannel["Tags"].array?.map({$0.string}),
																	lang: jChannel["Lang"].string ?? "ru")
                            } else {
                                print("ERROR: no id in \(jChannel)")
                            }
                        }
                    }
                } catch(let error) {
                    print(error)
                }
                 success([])
            })
            task.resume()
        }
    }
	
	func requestTracks(all: Bool = false) -> Observable<[TrackObject]> {
		let path = /*all ?*/ urlServices.tracks.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) /* :
		urlServices.tracksForStations.rawValue.appending(SubscribeManager.shared.requestString()).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)*/
		return Observable<[TrackObject]>.create({ (observer) -> Disposable in
			if let path = path, let url = URL(string: path) {
				
				let request = URLRequest(url: url)
				let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
					
					guard error == nil else {
						observer.onError(error!)
						return
					}
					
					guard let data = data else {
						return
					}
					
					do {
						let json  = try JSON(data: data)
						let realm = try Realm()
						if let tracks = json.array?.map({TrackObject.init(json: $0)}).filter({$0 != nil}).map({$0!}) {
							try realm.write {
								realm.delete(realm.objects(TrackObject.self))
								realm.add(tracks, update: true)
							}
						}
					} catch(let error) {
						print(error)
					}
					observer.onCompleted()
				})
				task.resume()
			}
			
			return Disposables.create {
				print("Track signal disposed")
			}
		})
	}
	
	func requestTracks(all: Bool = false, success: @escaping TracksLoaderSuccess, fail: @escaping ChannelsLoaderFail) {
		let path = /*all ?*/ urlServices.tracks.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) /* :
	urlServices.tracksForStations.rawValue.appending(SubscribeManager.shared.requestString()).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)*/
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
                        realm.delete(realm.objects(TrackObject.self))
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
    
    func subscribe(onChannel: Int, withCount: Int = 1) {
        if let str = String(format: urlServices.subForChannels.rawValue, onChannel).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
				if listen != 1 {
					do {
						let json  = try JSON(data: data)
						let realm = try Realm()
						try realm.write {
							DBManager.shared.track(fromJSON: json, realm: realm)
						}
					} catch(let error) {
						print(error)
					}
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
        channels = (UserDefaults.standard.array(forKey: "array_sub") as? [Int]) ?? []
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
    
	private (set) internal var channels = [Int]()
    private var listenedTracks = [Int]()
    
    public func requestString() -> String {
        return channels.map{ "\($0)" }.joined(separator: ",")
    }
    
    public func addOrDelete(channel: Int) {
        if hasChannel(id: channel) {
            removeChannel(id: channel)
        } else {
            addChannel(id: channel)
        }
        
        UserDefaults.standard.set(channels, forKey: "array_sub")
    }
    
    public func hasChannel(id: Int) -> Bool {
        return channels.contains(id)
    }
    
    private func addChannel(id: Int) {
        objc_sync_enter(channels)
        channels.append(id)
        objc_sync_exit(channels)
        
        debugPrint("user subscribed on \(id)")
        NotificationCenter.default.post(name: NotificationName.added.notification,
                                        object: nil,
                                        userInfo: ["id": id])
        
        DownloadManager.shared.subscribe(onChannel: id)
    }
    
    private func removeChannel(id: Int) {
        objc_sync_enter(channels)
        if let index = channels.index(of: id) {
            channels.remove(at: index)
        }
        objc_sync_exit(channels)
        
//        let realm = try! Realm()
//        try? realm.write {
//            realm.delete(realm.objects(Track.self).filter("station = %@", id))
//        }
		
        debugPrint("user unsubscribed on \(id)")
        NotificationCenter.default.post(name: NotificationName.deleted.notification,
                                        object: nil,
                                        userInfo: ["id": id])
        
        DownloadManager.shared.subscribe(onChannel: id, withCount: -1)
    }
    
}

class LikeManager {
    static let shared = LikeManager()
    
    private var channels = [Int]()
    
    init() {
        channels = (UserDefaults.standard.array(forKey: "array_like") as? [Int]) ?? []
    }
    
    public func addOrDelete(id: Int) {
        if hasObject(id: id) {
            dislike(id: id)
        } else {
            like(id: id)
        }
        
        UserDefaults.standard.set(channels, forKey: "array_like")
    }
    
    public func hasObject(id: Int) -> Bool {
        return channels.contains(id)
    }
    
    private func like(id: Int) {
        objc_sync_enter(channels)
        channels.append(id)
        objc_sync_exit(channels)
        
        debugPrint("user like on \(id)")
        
        DownloadManager.shared.track(id: id, like: 1)
    }
    
    private func dislike(id: Int) {
        objc_sync_enter(channels)
        if let index = channels.index(of: id) {
            channels.remove(at: index)
        }
        objc_sync_exit(channels)
        
        debugPrint("user dislike on \(id)")
        
        DownloadManager.shared.track(id: id, like: -1)
    }
}

class ListenManager {
    static let shared = ListenManager()
    
    private var channels = [Int]()
    
    init() {
        channels = (UserDefaults.standard.array(forKey: "array_listened") as? [Int]) ?? []
    }
    
    public func add(id: Int) {
        if !hasObject(id: id) {
            listened(id: id)
            UserDefaults.standard.set(channels, forKey: "array_listened")
        }
    }
    
    public func hasObject(id: Int) -> Bool {
        return channels.contains(id)
    }
    
    private func listened(id: Int) {
        objc_sync_enter(channels)
        channels.append(id)
        objc_sync_exit(channels)
        
        debugPrint("user listened \(id)")
        
        DownloadManager.shared.track(id: id, listen: 1)
    }
}
