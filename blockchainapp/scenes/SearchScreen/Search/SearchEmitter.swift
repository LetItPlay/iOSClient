//
//  SearchEmitter.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 16.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

enum SearchEvent {
    case searchChanged(string: String)
    case channelSubPressed(index: Int)
    case cellDidSelect(section: Int, index: Int)
    case showOthers(index: Int)
}

protocol SearchEmitterProtocol: LifeCycleHandlerProtocol {
    func send(event: SearchEvent)
}

class SearchEmitter: Emitter, SearchEmitterProtocol {
    
    weak var model: SearchEventHandler?
    weak var viewModel: SearchVMEmitterProtocol?
    
    convenience init(model: SearchEventHandler, viewModel: SearchVMEmitterProtocol) {
        self.init(handler: model as! ModelProtocol)
        
        self.model = model
        self.viewModel = viewModel
    }
    
    func send(event: SearchEvent) {
        switch event {
        case .cellDidSelect(let section, let index):
            self.model?.cellDidSelectFor(viewModels: (self.viewModel?.getTypeFor(section: section))!, atIndex: index)
        case .channelSubPressed(let index):
            self.model?.channelSubscriptionPressedAt(index: index)
        case .searchChanged(let string):
            self.model?.searchChanged(string: string)
        case .showOthers(let index):
            self.model?.showOthers(index: index)
        }
    }
}
