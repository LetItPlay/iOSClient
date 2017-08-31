//
//  Managers.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 29/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ChannelsLoaderSuccess = ([Station]) -> Void
typealias ChannelsLoaderFail = (Error?) -> Void

class DownloadManager {
    
    enum urlServices: String {
        case audiofiles = "http://176.31.100.18:8182/audiofiles/"
        case stations = "http://176.31.100.18:8182/stations/"
        case tracks = "http://176.31.100.18:8182/tracks/"
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
                    let station = Station(name: jStation["name"].string ?? "",
                                          image: jStation["image"].string ?? "",
                                          subscriptionCount: jStation["subscription_count"].int ?? 0)
                    result.append(station)
                }
                
                success(result)
            })
            task.resume()
        }
    }
    
}

