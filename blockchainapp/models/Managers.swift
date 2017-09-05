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
    
    func requestTracks(success: @escaping TracksLoaderSuccess, fail: @escaping ChannelsLoaderFail) {
        if let str = urlServices.tracks.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                    
                    let file = Audiofile(file: jTrack["audio_file"]["file"].string ?? "",
                                         lengthSeconds: jTrack["audio_file"]["length_seconds"].int64 ?? 0,
                                         sizeBytes: jTrack["audio_file"]["size_bytes"].int64 ?? 0)
                    
                    let t = Track(station: jTrack["station"].int ?? 0,
                                  audiofile: file,
                                  name: jTrack["name"].string ?? "",
                                  url: jTrack["url"].string ?? "",
                                  description: jTrack["description"].string ?? "",
                                  image: jTrack["image"].string ?? "",
                                  linkCount: jTrack["like_count"].int ?? 0,
                                  reportCount: jTrack["report_count"].int ?? 0)
                    result.append(t)
                }
                
                success(result)
            })
            task.resume()
        }
    }
    
}

