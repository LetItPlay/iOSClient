//
// Created by Aleksey Tyurnin on 12/02/2018.
// Copyright (c) 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire.Swift
import SwiftyJSON
import RealmSwift

enum TracksRequest {
    case feed(channels: [Int], offset: Int, count: Int)
    case trends(offset: Int, count: Int)
    case likes
    case channel(Int)
    case tag(String)
    case magic
	case allTracks
	case search(text: String, offset: Int, count: Int)
}

enum TrackUpdateRequest {
    case listen
    case like(count: Int)
    case report(msg: String)
}

enum ChannelUpdateRequest {
    case subscribe(count: Int)
    case report(msg: String)
}

fileprivate extension TracksRequest {
    func urlQuery(lang: String) -> String {
        switch self {
        case .feed(let channels, let offset, let count):
            let channelsString = channels.map({"\($0)"}).joined(separator: ",")
            return "feed?stIds=\(channelsString)&offset=\(offset)&limit=\(count)&lang=\(lang)"
        case .trends(let offset, let count):
            return "trends?offset=\(offset)&limit=\(count)&lang=\(lang)"
        case .channel(let id):
            return "stations/\(id)/tracks"
        case .tag(let tag):
            return "tags/\(tag)"
        case .magic:
            return "abrakadabra?lang=\(lang)"
        default: return "tracks"
        }
    }
}

enum Result<T> {
    case value(T)
    case error(Error)
}

enum RequestError: Error {
    case invalidURL
    case invalidJSON
    case noConnection
    case serverError(code: Int, msg: String)
}

class RequestManager {

    static let server: String = "https://beta.api.letitplay.io"
	static let shared: RequestManager = RequestManager()

	func channel(id: Int) -> Observable<Channel> {
		let urlString = RequestManager.server + "/stations/\(id)"
		if let url = URL(string: urlString) {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			let getSignal = self.request(request: request).retry().flatMap({ (result) -> Observable<Channel> in
				switch result {
				case .value(let data):
					if let json = try? JSON(data: data), var channel: Channel = Channel(json: json) {
						let lm = LikeManager.shared
						channel.isSubscribed = lm.hasObject(id: channel.id)
						return Observable.just(channel)
					} else {
						return Observable.error(RequestError.invalidJSON)
					}
				case .error(let error):
					return Observable.error(error)
				}
			})
			
			if let channel = (try? Realm())?.object(ofType: ChannelObject.self, forPrimaryKey: id)?.plain() {
				return Observable.from([Observable.just(channel), getSignal]).flatMap({$0})
			} else {
				return getSignal
			}
		}
		return Observable.error(RequestError.invalidURL)
	}
    
    func track(id: Int) -> Observable<Track> {
        let urlString = RequestManager.server + "/tracks/\(id)"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let getSignal = self.request(request: request).retry().flatMap({ (result) -> Observable<Track> in
                switch result {
                case .value(let data):
                    if let json = try? JSON(data: data), var track: Track = Track(json: json) {
                            let lm = LikeManager.shared
                            track.isLiked = lm.hasObject(id: track.id)
                            return Observable.just(track)
                    } else {
                        return Observable.error(RequestError.invalidJSON)
                    }
                case .error(let error):
                    return Observable.error(error)
                }
            })
            
            return getSignal
        }
        return Observable.error(RequestError.invalidURL)
    }
	
	func search(text: String, offset: Int, count: Int) -> Observable<([Track], [Channel])> {
		let urlString = RequestManager.server + "/" + "search?q=\(text.lowercased())&offset=\(offset)&limit=\(count)&lang=\(UserSettings.language.rawValue)"
		if let url = urlString.url() {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			return self.request(request: request).retry().flatMap({ (result) -> Observable<([Track],[Channel])> in
				print(url.absoluteString)
				switch result {
				case .value(let data):
					do {
						let lm = LikeManager.shared
						let json = try JSON(data: data)
						
						var tracks = [Track]()
						var channels = [Channel]()
						if let items = json["results"].array {
							for item in items {
								if let track = Track.init(json: item) {
									tracks.append(track)
								} else if let channel = Channel.init(json: item) {
									channels.append(channel)
								}
							}
						}
						return Observable.just((tracks, channels))
					} catch {
						return Observable.error(RequestError.invalidJSON)
					}
				case .error(let error):
					return Observable.error(error)
				}
			})
		}
		return Observable.error(RequestError.invalidURL)
	}
	
    func tracks(req: TracksRequest) -> Observable<[Track]> {
        let urlString = RequestManager.server + "/" + req.urlQuery(lang: UserSettings.language.rawValue)
        if let url = URL(string: urlString) {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			return self.request(request: request).retry().flatMap({ (result) -> Observable<[Track]> in
				print(url.absoluteString)
				switch result {
				case .value(let data):
					do {
						let lm = LikeManager.shared
						let json = try JSON(data: data)
						
						let channels: [Channel] = json["Stations"].array?
							.map({Channel(json: $0)})
							.filter({$0 != nil}).map({$0!}) ?? []
                        let tracksJSON: JSON!
                        switch req {
                        case .magic:
                            tracksJSON = json["Tracks"]
                        default:
                            tracksJSON = json
                        }
						let tracks: [Track] = tracksJSON.array?
							.map({Track(json: $0)})
							.filter({$0 != nil}).map({$0!})
							.map({track in
								var track = track
								track.isLiked = lm.hasObject(id: track.id)
								return track}) ?? []
						let objs = json["Stations"].array?.map({ (json) -> ChannelObject? in
							return ChannelObject.init(json: json)
						}).filter({$0 != nil}).map({$0!}) ?? []
						let realm = try? Realm()
						try? realm?.write {
							realm?.add(objs, update: true)
						}
						return Observable.just(tracks)
					} catch {
						return Observable.error(RequestError.invalidJSON)
					}
				case .error(let error):
					return Observable.error(error)
				}
			})
        }
        return Observable.error(RequestError.invalidURL)
    }
    
    func channels(offset: Int = 0, count: Int = 100) -> Observable<[Channel]> {
        let urlString = RequestManager.server + "/stations?offset=\(offset)&count=\(count)&lang=\(UserSettings.language.rawValue)"
        if let url = URL(string: urlString) {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			return self.request(request: request).retry().flatMap({ (result) -> Observable<[Channel]> in
				switch result {
				case .value(let data):
					do {
						let subMan = SubscribeManager.shared
						let json = try JSON(data: data)
						let channels: [Channel] = json.array?
							.map({Channel(json: $0)})
							.filter({$0 != nil}).map({channel in
								var channel = channel!
								channel.isSubscribed = subMan.hasChannel(id: channel.id)
								return channel
							}) ?? []
						let objs = json.array?.map({ (json) -> ChannelObject? in
							return ChannelObject.init(json: json)
						}).filter({$0 != nil}).map({$0!}) ?? []
						let realm = try? Realm()
						try? realm?.write {
							realm?.add(objs, update: true)
						}
						return Observable.just(channels)
					} catch {
						return Observable.error(RequestError.invalidJSON)
					}
				case .error(let error):
					return Observable.error(error)
				}
			})
		}
        return Observable.error(RequestError.invalidURL)
    }
    
    func updateChannel(id: Int, type: ChannelUpdateRequest) -> Observable<Bool> {
        return Observable<Bool>.create({ (observer) -> Disposable in
            if let str = String(format: "https://manage.letitplay.io/api/stations/%d/counts/", id).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: str) {
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                var elements: [String: Int] = [:]
                elements["report_count"] = 0
                elements["subscription_count"]   = 0
                
                switch type {
                case .subscribe(let count):
                    elements["subscription_count"] = count
                case .report(_):
                    elements["report_count"] = 1
                }
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted)
                
                Alamofire.request(request)
                    .responseData { (response: DataResponse<Data>) in
                        
                        if let _ = response.error {
                            observer.onError(RequestError.noConnection)
                            observer.onCompleted()
                            return
                        }
                        
                        if let resp = response.response, let data = response.data {
                            if resp.statusCode == 200 {
                                do {
                                    let _  = try JSON(data: data)
//                                    if let channel = Station1.init(json: json) {
//                                        observer.onNext(channel.isSubscribed)
//                                    } else {
//                                        observer.onError(RequestError.invalidJSON)
//                                    }
                                    observer.onNext(true)
                                } catch(let error) {
                                    print(error)
                                    observer.onError(RequestError.invalidJSON)
                                }
                            } else {
                                observer.onError(RequestError.serverError(code: resp.statusCode, msg: String(data: data, encoding: .utf8) ?? ""))
                            }
                        } else {
                            observer.onError(RequestError.noConnection)
                        }
                        observer.onCompleted()
                }
            } else {
                observer.onError(RequestError.invalidURL)
            }
            
            return Disposables.create {
                print("Track update signal disposed")
            }
        })
    }
    
    func updateTrack(id: Int, type: TrackUpdateRequest) -> Observable<(Int, Int, Int)> {
        return Observable<(Int, Int, Int)>.create({ (observer) -> Disposable in
            if let str = String(format: "https://manage.letitplay.io/api/tracks/%d/counts/", id).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: str) {
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                var elements: [String: Int] = [:]
                elements["report_count"] = 0
                elements["like_count"]   = 0
                elements["listen_count"] = 0
                switch type {
                    case .like(let count):
                        elements["like_count"] = count
                    case .report(_):
                        elements["report_count"] = 1
                    case .listen:
                        elements["listen_count"] = 1
                }
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted)
				
                Alamofire.request(request)
					.responseData { (response: DataResponse<Data>) in
						
						if let _ = response.error {
							observer.onError(RequestError.noConnection)
							observer.onCompleted()
							return
						}
						
						if let resp = response.response, let data = response.data {
							if resp.statusCode == 200 {
								do {
									let json  = try JSON(data: data)
                                    if let likes = json["like_count"].int,
                                       let reports = json["report_count"].int,
                                       let listens = json["listen_count"].int
                                    {
                                        observer.onNext((likes, reports, listens))
									} else {
										observer.onError(RequestError.invalidJSON)
									}
								} catch(let error) {
									print(error)
									observer.onError(RequestError.invalidJSON)
								}
							} else {
								observer.onError(RequestError.serverError(code: resp.statusCode, msg: String(data: data, encoding: .utf8) ?? ""))
							}
						} else {
							observer.onError(RequestError.noConnection)
						}
						observer.onCompleted()
				}
			} else {
				observer.onError(RequestError.invalidURL)
			}
			
            return Disposables.create {
                print("Track update signal disposed")
            }
        })
    }
	
	func request(request: URLRequest) -> Observable<Result<Data>>{
		return Observable<Result<Data>>.create({ (observer) -> Disposable in
			Alamofire.request(request).responseData { (response: DataResponse<Data>) in
				if let _ = response.error {
					observer.onError(RequestError.noConnection)
					observer.onCompleted()
					return
				}
				if let resp = response.response, let data = response.data {
					if resp.statusCode == 200 {
						observer.onNext(.value(data))
					} else {
						observer.onNext(.error(RequestError.serverError(code: resp.statusCode, msg: String(data: data, encoding: .utf8) ?? "")))
					}
				} else {
					observer.onError(RequestError.noConnection)
				}
				observer.onCompleted()
			}
			return Disposables.create {
				let empty = "without url"
				print("Request \(request.url?.absoluteString ?? empty) signal disposed")
			}
		})
	}
}
