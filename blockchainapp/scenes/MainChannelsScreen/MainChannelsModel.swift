//
//  MainChannelsModel.swift
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
    func showChannel(section: Int, index: Int)
    func showAllChannelsFor(section: Int)
    func refresh()
}

protocol MainChannelsModelDelegate: class {
    func reload(categories: [ChannelCategoryViewModel])
    func showChannel(id: Int)
    func showAllChannelsFor(category: Int, title: String)
}

class MainChannelsModel: MainChannelsModelProtocol, MainChannelsEventHandler {
    var delegate: MainChannelsModelDelegate?
    
    var categories: [ChannelCategory] = []
    
    let getChannelsAction: Action<Bool, [ChannelCategory]>!
    var disposeBag = DisposeBag()
    
    init() {
        
        self.getChannelsAction = Action<Bool, [ChannelCategory]>.init(workFactory: { (_) -> Observable<[ChannelCategory]> in
            return RequestManager.shared.categories()
        })
        
        self.getChannelsAction.elements.subscribe(onNext: { categories in
            self.categories = categories.filter({$0.channels.count != 0})
            self.delegate?.reload(categories: self.categories.map({ChannelCategoryViewModel(category: $0)}))
        }).disposed(by: disposeBag)
        
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.refresh()
        default:
            break
        }
    }
    
    func showAllChannelsFor(section: Int) {
        self.delegate?.showAllChannelsFor(category: categories[section].id, title: categories[section].name)
    }
    
    func showChannel(section: Int, index: Int) {
        self.delegate?.showChannel(id: categories[section].channels[index].id)
    }
    
    func refresh() {
        self.getChannelsAction.execute(true)
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
