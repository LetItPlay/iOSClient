//
// Created by Aleksey Tyurnin on 12/02/2018.
// Copyright (c) 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

enum TracksRequest {
    case feed(stations: [Int], offset: Int, count: Int)
    case trends(Int)
    case likes
    case channel(Int)
    case tag(String)
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
        case .feed(let stations, let offset, let count):
            let stationsString = stations.map({"\($0)"}).joined(separator: ",")
            return "feed?stIds=\(stationsString)&offset=\(offset)&limit=\(count)&lang=\(lang)"
        case .trends(let days):
            return "trends/\(days)?lang=\(lang)"
        case .channel(let id):
            return "stations/\(id)/tracks"
        case .tag(let tag):
            return "tags/\(tag)"
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

    static let server: String = "https://api.letitplay.io"
	static let shared: RequestManager = RequestManager()

    func tracks(req: TracksRequest) -> Observable<([Track1],[Station1])> {
        let urlString = RequestManager.server + "/" + req.urlQuery(lang: UserSettings.language.rawValue)
        if let url = URL(string: urlString) {
            return Observable<([Track1],[Station1])>.create { observer in
                Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
                        .responseData { (response: DataResponse<Data>) in

                            if let _ = response.error {
                                observer.onError(RequestError.noConnection)
                                observer.onCompleted()
                                return
                            }

							if let resp = response.response, let data = response.data {
                                if resp.statusCode == 200 {
                                    do {
										let lm = LikeManager.shared
                                        let json = try JSON(data: data)
										let stations: [Station1] = json["Stations"].array?
                                                .map({Station1(json: $0)})
                                                .filter({$0 != nil}).map({$0!}) ?? []
										let tracks: [Track1] = json["Tracks"].array?
											.map({Track1(json: $0)})
											.filter({$0 != nil}).map({$0!})
											.map({track in track.isLiked = lm.hasObject(id: track.id); return track}) ?? []
                                        observer.onNext((tracks, stations))
                                    } catch {
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
                return Disposables.create {
                    print("Track signal \(req) disposed")
                }
            }
        }
        return Observable.error(RequestError.invalidURL)
    }
    
    func channels(offset: Int = 0, count: Int = 100) -> Observable<[Station1]> {
        let urlString = RequestManager.server + "/stations?offset=\(offset)&count=\(count)&lang=\(UserSettings.language.rawValue)"
        if let url = URL(string: urlString) {
            return Observable<[Station1]>.create({ (observer) -> Disposable in
                
                    Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
                        .responseData { (response: DataResponse<Data>) in
                            
                            if let _ = response.error {
                                observer.onError(RequestError.noConnection)
                                observer.onCompleted()
                                return
                            }
                            
                            if let resp = response.response, let data = response.data {
                                if resp.statusCode == 200 {
                                    do {
                                        let json = try JSON(data: data)
                                        let stations: [Station1] = json.array?
                                            .map({Station1(json: $0)})
                                            .filter({$0 != nil}).map({station in
                                                var station = station!
                                                station.isSubscribed = SubscribeManager.shared.hasStation(id: station.id)
                                                return station
                                            }) ?? []
                                        observer.onNext(stations)
                                    } catch {
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
                return Disposables.create {
                    print("Channels signal disposed")
                }
            })
        }
        return Observable.error(RequestError.invalidURL)
    }
    
    func channelUpdate(id: Int, type: ChannelUpdateRequest) -> Observable<Station1> {
        return Observable<Station1>.create({ (observer) -> Disposable in
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
                case .report(let _):
                    elements["report_count"] = 1
                }
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted)
                
                Alamofire.request(url, method: .post, parameters: elements, encoding: URLEncoding.default, headers: nil)
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
                                    if let channel = Station1.init(json: json) {
                                        observer.onNext(channel)
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
    
    func trackUpdate(id: Int, type: TrackUpdateRequest) -> Observable<Track1> {
        return Observable<Track1>.create({ (observer) -> Disposable in
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
                        elements["like_count"]   = count
                    case .report(let _):
                        elements["report_count"] = 1
                    case .listen:
                        elements["listen_count"] = 1
                }
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted)
				
				Alamofire.request(url, method: .post, parameters: elements, encoding: URLEncoding.default, headers: nil)
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
									if let track = Track1.init(json: json) {
										observer.onNext(track)
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
}
