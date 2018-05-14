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
    var shareInfo: ShareInfo? {get set}
}

protocol OthersEventHandler: class {
    func report(cause: ReportEventCause)
    func shareTrack(viewController: UIViewController)
    func showHiddenChannels()
    func okButtonTouched()
    func hideChannel()
}

protocol OthersModelDelegate: class {
    func set(objectToShare: ShareObjectType)
    func share(trackShareInfo: ShareInfo, viewController: UIViewController)
    func showHiddenChannels()
}

class OthersModel: OthersModelProtocol, OthersEventHandler {
    weak var delegate: OthersModelDelegate?
    var shareInfo: ShareInfo?
    
    var disposeBag = DisposeBag()
    
    init(infoToShare: ShareInfo) {
        self.shareInfo = infoToShare
    }
    
    func report(cause: ReportEventCause) {
        RequestManager.shared.updateTrack(id: (self.shareInfo?.id)!, type: .report(msg: "\(cause)")).subscribe(onNext: { (tuple) in
        }).disposed(by: disposeBag)
    }
    
    func shareTrack(viewController: UIViewController) {
        self.delegate?.share(trackShareInfo: self.shareInfo!, viewController: viewController)
    }
    
    func showHiddenChannels() {
        self.delegate?.showHiddenChannels()
    }
    
    func okButtonTouched() {
        switch self.shareInfo?.type {
        case .channel?:
            self.hideChannel()
        default:
            break
        }
    }
    
    func hideChannel() {
        print("\nHide channel \((self.shareInfo?.id)!)")
        RequestManager.shared.updateChannel(id: (self.shareInfo?.id)!, type: .hide).subscribe(onNext: { (channel) in
        }).disposed(by: disposeBag)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.delegate?.set(objectToShare: (self.shareInfo?.type)!)
        default:
            break
        }
    }
}
