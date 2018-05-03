//
//  OthersEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

enum ReportEventCause {
    case spam, adultContent, cruelContent
}

enum OthersEvent {
    case report(ReportEventCause), shareTrack(viewController: UIViewController)
}

protocol OthersEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: OthersEvent)
}

class OthersEmitter: Emitter, OthersEmitterProtocol {
    
    weak var model: OthersEventHandler?
    
    convenience init(model: OthersEventHandler) {
        self.init(handler: model as! ModelProtocol)
        self.model = model
    }
    
    func send(event: OthersEvent) {
        switch event {
        case .report(let cause):
            self.model?.report(cause: cause)
        case .shareTrack(let viewController):
            self.model?.shareTrack(viewController: viewController)
        }
    }
}
