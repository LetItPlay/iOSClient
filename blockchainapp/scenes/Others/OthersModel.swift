//
//  OthersModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol OthersModelProtocol: ModelProtocol {
    var delegate: OthersModelDelegate? {get set}
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
    weak var delegate: OthersModelDelegate?
    var trackShareInfo: ShareInfo?
    
    var disposeBag = DisposeBag()
    
    var trackID: Int!
    
    init(track: ShareInfo) {
        self.trackShareInfo = track
    }
    
    func report(cause: ReportEventCause) {
        RequestManager.shared.updateTrack(id: self.trackID, type: .report(msg: "\(cause)")).subscribe(onNext: { (tuple) in
        }).disposed(by: disposeBag)
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
