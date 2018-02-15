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
                                        let json = try JSON(data: data)
                                        let stations = json["Stations"].array?
                                                .map({Station1(json: $0)})
                                                .filter({$0 != nil}).map({$0!}) ?? []
                                        let tracks = json["Tracks"].array?
                                                .map({Track1(json: $0)})
                                                .filter({$0 != nil}).map({$0!}) ?? []
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

}
