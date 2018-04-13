//
//  OthersModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol OthersModelProtocol: class, ModelProtocol {
    weak var delegate: OthersModelDelegate? {get set}
    var trackShareInfo: ShareInfo? {get set}
}

protocol OthersEventHandler: class {
    func report(cause: ReportEventCause)
    func shareTrack(viewController: UIViewController)
}

protocol OthersModelDelegate: class {
    func share(trackShareInfo: ShareInfo, viewController: UIViewController)
}

class OthersModel: OthersModelProtocol, OthersEventHandler {
    var delegate: OthersModelDelegate?
    var trackShareInfo: ShareInfo?
    
    var disposeBag = DisposeBag()
    
    var trackID: Int!
    
    init(track: Any) {
//        self.getData(trackId: trackID)
        
        DispatchQueue.global(qos: .background).async {
            if let track = track as? Track {
                self.trackShareInfo = ShareInfo(text: "\"\(track.name)\" - \(track.channel.name)",
                    url: RequestManager.server + "/tracks/\(track.id)",
                    image: try! UIImage(data: Data(contentsOf: (track.image)!))!)
                
                self.trackID = track.id
            }
            if let track = track as?  AudioTrack {
                self.trackShareInfo = ShareInfo(text: "\"\(track.name)\" - \(track.author)",
                    url: RequestManager.server + "/tracks/\(track.id)",
                    image: try! UIImage(data: Data(contentsOf: (track.imageURL)!))!)
                
                self.trackID = track.id
            }
            
            if let track = track as? TrackObject {
                self.trackShareInfo = ShareInfo(text: "\"\(track.name)\" - \(track.channel)",
                    url: RequestManager.server + "/tracks/\(track.id)",
                    image: (try! UIImage(data: Data.init(contentsOf: track.image.url()!)))!)
                
                self.trackID = track.id
            }
        }
    }
    
//    func getData(track: Int) {
//        RequestManager.shared.track(id: trackId).subscribe(onNext: { (tuple) in
//            self.trackShareInfo = TrackShareInfo(text: "\"\(tuple.name)\" - \(tuple.channel.name)",
//                                                 url: RequestManager.server + "/tracks/\(tuple.id)",
//                                                 image: try! UIImage(data: Data(contentsOf: (tuple.image)!))!)
//            self.delegate?.add(track: self.trackShareInfo!)
//        }).disposed(by: disposeBag)
//    }
    
    func report(cause: ReportEventCause) {
        RequestManager.shared.updateTrack(id: self.trackID, type: .report(msg: "\(cause)"))
    }
    
    func shareTrack(viewController: UIViewController) {
        self.delegate?.share(trackShareInfo: self.trackShareInfo!, viewController: viewController)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            break
        default:
            break
        }
    }
}
