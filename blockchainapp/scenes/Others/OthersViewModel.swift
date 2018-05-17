//
//  OthersViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

struct OthersAlertData {
    var actionTitle: String
    var alertTitle: String
    var alertMessage: String
    
    var alertAcrions: [(title: String, event: OthersEvent)]
    var showOkButton: Bool
    
    init(actionTitle: String, alertTitle: String, alertMessage: String, alertActions: [(title: String, event: OthersEvent)], showOkButton: Bool) {
        self.actionTitle = actionTitle
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        
        self.alertAcrions = alertActions
        self.showOkButton = showOkButton
    }
}

protocol OthersVMProtocol {
    var delegate: OthersVMDelegate? {get set}
    
    var alertData: OthersAlertData {get}
    var objectToShare: ShareObjectType! {get set}
}

protocol OthersVMDelegate: class {
}

class OthersViewModel: OthersVMProtocol, OthersModelDelegate {
    weak var delegate: OthersVMDelegate?
    var model: OthersModelProtocol!
    
    var objectToShare: ShareObjectType!

    var alertData: OthersAlertData {
        get {
            switch self.objectToShare! {
            case .track:
                return OthersAlertData(actionTitle: LocalizedStrings.Others.report, alertTitle: LocalizedStrings.Others.reportOn, alertMessage: "", alertActions: [(title: LocalizedStrings.Others.Reports.spam, event: OthersEvent.report(.spam)), (title: LocalizedStrings.Others.Reports.adultContent, event: OthersEvent.report(.adultContent)), (title: LocalizedStrings.Others.Reports.cruelContent, event: OthersEvent.report(.cruelContent))], showOkButton: false)
            case .channel:
                return OthersAlertData(actionTitle: LocalizedStrings.Others.notShow, alertTitle: LocalizedStrings.Others.notShow, alertMessage: LocalizedStrings.Others.notShowDescription, alertActions: [(title: LocalizedStrings.Others.showHiddenChannels, event: OthersEvent.showHidden)], showOkButton: true)
            }
        }
    }
    
    init(model: OthersModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func set(objectToShare: ShareObjectType) {
        self.objectToShare = objectToShare
    }
    
    func share(trackShareInfo: ShareInfo, viewController: UIViewController) {
        MainRouter.shared.share(data: trackShareInfo, viewController: viewController)
    }
    
    func showHiddenChannels() {
        MainRouter.shared.show(screen: "category", params: ["filter" : ChannelsFilter.hidden], present: false)
    }
}
