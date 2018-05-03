//
//  MainChannelModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 26.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import Action

protocol MainChannelsModelProtocol: ModelProtocol {
    var delegate: MainChannelsModelDelegate? {get set}
}

protocol MainChannelsEventHandler: class {
    func showChannel(section: String, index: Int)
    func showAllChannelsFor(section: String)
}

protocol MainChannelsModelDelegate: class {
    func reload(categories: [String : [CategoryChannelViewModel]])
    func showChannel(id: Int)
    func showAllChannelsFor(category: String)
}

class MainChannelsModel: MainChannelsModelProtocol, MainChannelsEventHandler {
    var delegate: MainChannelsModelDelegate?
    
    var categories: [String : [Channel]] = [:]
    
    let getChannelsAction: Action<Bool, [Channel]>!
    var disposeBag = DisposeBag()
    
    init() {
        
        self.getChannelsAction = Action<Bool, [Channel]>.init(workFactory: { (_) -> Observable<[Channel]> in
            return RequestManager.shared.channels()
        })
        
        self.getChannelsAction.elements.subscribe(onNext: { channels in
            self.categories = ["Auto" : Array(channels[0...5]), "Some others" : Array(channels[6...10])]
            self.delegate?.reload(categories: self.categories.mapValues({ (channels) -> [CategoryChannelViewModel] in
                return channels.map({CategoryChannelViewModel(channel: $0)})
            }))
        }).disposed(by: disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
        self.getChannelsAction.execute(true)

    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.getChannelsAction.execute(true)
        default:
            break
        }
    }
    
    func showAllChannelsFor(section: String) {
        self.delegate?.showAllChannelsFor(category: section)
    }
    
    func showChannel(section: String, index: Int) {
        self.delegate?.showChannel(id: categories[section]![index].id)
    }
}

extension MainChannelsModel: ChannelUpdateProtocol {
    func channelUpdated(channel: Channel) {
//        if let index = self.channels.index(where: {$0.id == channel.id}) {
//            self.channels[index] = channel
//            self.delegate?.update(index: index, vm: self.channelScreen == .small ? SmallChannelViewModel(channel: self.channels[index]) : MediumChannelViewModel(channel: self.channels[index]))
//        }
    }
}
