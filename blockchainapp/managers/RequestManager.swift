//
// Created by Aleksey Tyurnin on 12/02/2018.
// Copyright (c) 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON
import RealmSwift
import Action

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
    case like
    case dislike
    case report(msg: String)
}

enum ChannelUpdateRequest {
    case subscribe
    case unsubscribe
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
    case unAuth(prev: String?)
    case serverError(code: Int, msg: String)
}

class RequestManager {

    static let server: String = "https://api.letitplay.io"
	static let shared: RequestManager = RequestManager()
    
    private var jwt: Variable<String?> = Variable<String?>(nil)
    var sessionManager: SessionManager!
    let disposeBag = DisposeBag()
    
    init() {

//        var proxyConfiguration = [NSObject: AnyObject]()
//        proxyConfiguration[kCFNetworkProxiesHTTPProxy] = "128.140.175.97" as AnyObject?
//        proxyConfiguration[kCFNetworkProxiesHTTPPort] = "443" as AnyObject?
//        proxyConfiguration[kCFNetworkProxiesHTTPEnable] = 1 as AnyObject?
//        proxyConfiguration[kCFStreamPropertyHTTPSProxyHost] = "128.140.175.97" as AnyObject?
//        proxyConfiguration[kCFStreamPropertyHTTPSProxyPort] = 443 as AnyObject?
        let cfg = Alamofire.SessionManager.default.session.configuration
//        cfg.connectionProxyDictionary = proxyConfiguration

        self.sessionManager = SessionManager.init(configuration: cfg)
    }
    
	func channel(id: Int) -> Observable<Channel> {
		let urlString = RequestManager.server + "/stations/\(id)"
		if let url = URL(string: urlString) {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			let getSignal = self.makeRequest(request).flatMap({ (result) -> Observable<Channel> in
				switch result {
				case .value(let data):
					if let json = try? JSON(data: data), var channel: Channel = Channel(json: json) {
                        channel.isSubscribed = SubscribeManager.shared.hasChannel(id: channel.id)
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
            let getSignal = self.makeRequest(request).flatMap({ (result) -> Observable<Track> in
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
			return self.makeRequest(request).flatMap({ (result) -> Observable<([Track], [Channel])> in
				print(url.absoluteString)
				switch
                result {
				case .value(let data):
					do {
						let lm = LikeManager.shared
                        let subscribeManager = SubscribeManager.shared
						let json = try JSON(data: data)
						var tracks = [Track]()
						var channels = [Channel]()
						if let items = json["results"].array {
							for item in items {
								if var track = Track.init(json: item) {
                                    track.isLiked = lm.hasObject(id: track.id)
									tracks.append(track)
								} else if var channel = Channel.init(json: item) {
                                    channel.isSubscribed = subscribeManager.hasChannel(id: channel.id)
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
			return self.makeRequest(request).flatMap({ (result) -> Observable<[Track]> in
				print(url.absoluteString)
				switch result {
				case .value(let data):
					do {
						let lm = LikeManager.shared
						let json = try JSON(data: data)
						
						let _: [Channel] = json["Stations"].array?
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
			return self.makeRequest(request).flatMap({ (result) -> Observable<[Channel]> in
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

    func updateChannel(id: Int, type: ChannelUpdateRequest) -> Observable<Channel> {
        var urlString = RequestManager.server
        switch type {
            case .report(_):
                urlString += "/report/channel/\(id)"
            default:
                urlString += "/follow/channel/\(id)"
        }
        guard let str = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) else {
                return Observable<Channel>.error(RequestError.invalidURL)
        }
        
        var bodyString = ""
        
        var req = URLRequest(url: url)
        switch type {
        case .unsubscribe:
            req.httpMethod = "DELETE"
        case .subscribe:
            req.httpMethod = "PUT"
        case .report(let msg):
            req.httpMethod = "PUT"
            bodyString = "reason:\(msg)"
        }

        req.httpBody = bodyString.data(using: .utf8)
        req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return makeRequest(req).flatMap({ result -> Observable<Channel> in
            switch result {
            case .value(let data):
                if let json = try? JSON(data: data), let ch = Channel.init(json: json) {
                    return Observable.just(ch)
                }
                return Observable<Channel>.error(RequestError.invalidJSON)
            case .error(let error):
                return Observable<Channel>.error(error)
            }
        })
    }
    
    func updateTrack(id: Int, type: TrackUpdateRequest) -> Observable<Track> {
        var urlString = RequestManager.server
        switch type {
        case .report(_):
            urlString += "/report/track/\(id)"
        default:
            urlString += "/like/track/\(id)"
        }
        guard let str = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: str) else {
                return Observable<Track>.error(RequestError.invalidURL)
        }
            
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var body = ""

        switch type {
        case .dislike:
            request.httpMethod = "DELETE"
        case .report(let msg):
            request.httpMethod = "PUT"
            body = "reason:\(msg)"
        default:
            request.httpMethod = "PUT"
        }
        request.httpBody = body.data(using: .utf8)

        return makeRequest(request).flatMap { result -> Observable<Track> in
            switch result {
            case .value(let data):
                if let json = try? JSON(data: data),
                   let tr = Track.init(json: json),
                   let ch = Channel.init(json: json["station"]) {

                    return Observable.just(tr)
                }
                return Observable<Track>.error(RequestError.invalidJSON)
            case .error(let error):
                return Observable<Track>.error(error)
            }
         }
    }
    
    private func renewToken() -> Observable<String> {
        let urlString = RequestManager.server + "/auth/signup?uid=\(UserSettings.userIdentifier)&username=\(UserSettings.name)"
        if let url = URL(string: urlString), var request = try? URLRequest.init(url: url, method: HTTPMethod.post) {
            request.httpMethod = "POST"
            
            return Observable<String>.create({ (observer) -> Disposable in
                let dataReq: DataRequest = Alamofire.request(request).responseData { (response: DataResponse<Data>) in
                    if let _ = response.error {
                        observer.onError(RequestError.noConnection)
                        return
                    }
                    guard let resp = response.response, let data = response.data else {
                        observer.onError(RequestError.noConnection)
                        return
                    }
                    switch resp.statusCode {
                    case 200:
                        let jwt = (resp.allHeaderFields["Authorization"] as? String ?? "").replacingOccurrences(of: "Bearer ", with: "")
                        observer.onNext(jwt)
                    default:
                        observer.onError(RequestError.serverError(code: resp.statusCode, msg: String(data: data, encoding: .utf8) ?? ""))
                    }
                    observer.onCompleted()
                }
                return Disposables.create { print("🔑 JWT signal disposed"); dataReq.cancel()}
            })
        }
        return Observable<String>.error(RequestError.invalidURL)
    }
    
    private func simpleRequest(req: URLRequest) -> Observable<Result<Data>> {
        guard let jwt = self.jwt.value else {
            return Observable<Result<Data>>.error(RequestError.unAuth(prev: self.jwt.value))
        }
        var requsest = req
        requsest.allHTTPHeaderFields?["Authorization"] = "Bearer " + jwt
        return Observable<Result<Data>>.create({ (observer) -> Disposable in
            let dataReq: DataRequest = self.sessionManager.request(requsest).responseData { (response: DataResponse<Data>) in
                if let _ = response.error {
                    observer.onError(RequestError.noConnection)
                    return
                }
                guard let resp = response.response, let data = response.data else {
                    observer.onError(RequestError.noConnection)
                    return
                }
                switch resp.statusCode {
                case 200:
                    observer.onNext(.value(data))
                case 403:
                    observer.onError(RequestError.unAuth(prev: jwt))
                default:
                    observer.onError(RequestError.serverError(code: resp.statusCode, msg: String(data: data, encoding: .utf8) ?? ""))
                }
                observer.onCompleted()
            }
            return Disposables.create { print("📤 Request disposed"); dataReq.cancel()}
        })
    }
	
	func makeRequest(_ request: URLRequest) -> Observable<Result<Data>>{
//        let signal = simpleRequest(req: request).retryWhen({ (obs) -> Observable<String> in
//            return obs.flatMap({ (error) -> Observable<String> in
//                switch error {
//                case RequestError.unAuth:
//                    return self.renewToken().do(onNext: { (jwt) in
//                        self.jwt.value = jwt
//                    })
//                default: return Observable<String>.just(self.jwt.value ?? "")
//                }
//            })
//        })
//
        let signal = simpleRequest(req: request)
            .catchError({ (error) -> Observable<Result<Data>> in
                print(request)
                switch error {
                case RequestError.unAuth:
                    return self.renewToken().asObservable().do(onNext: { (jwt) in
                        self.jwt.value = jwt
                    }).flatMap({ _ -> Observable<Result<Data>> in
                        return self.simpleRequest(req: request)
                    })
                default: return Observable<Result<Data>>.error(error)
                }
            }).retry()

        return signal
	}
}
