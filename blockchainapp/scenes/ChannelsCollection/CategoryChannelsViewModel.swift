//
//  CategoryChannelsViewModel.swift
//  blockchainapp
//
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol CategoryChannelsVMProtocol {
    var channels: [SmallChannelViewModel] {get}
    var category: String {get set}
    var hideEmptyMessage: Bool {get set}
    
    var delegate: CategoryChannelsVMDelegate? {get set}
}

protocol CategoryChannelsVMDelegate: class  {
    func reloadChannels()
    func updateEmptyMessage()
}

class CategoryChannelsViewModel: CategoryChannelsVMProtocol, CategoryChannelsModelDelegate {
    
    var channels: [SmallChannelViewModel] = []
    var category: String = ""
    var hideEmptyMessage: Bool = false
    weak var delegate: CategoryChannelsVMDelegate?
    var model:  CategoryChannelsModelProtocol!
    
    init(model:  CategoryChannelsModelProtocol) {
        self.model = model
        self.model.delegate = self
    }
    
    func reload(newChannels: [SmallChannelViewModel]) {
        self.channels = newChannels
        self.delegate?.reloadChannels()
        if self.channels.count == 0 {
            self.updateEmptyMessage(hide: true)
        } else {
            self.updateEmptyMessage(hide: false)
        }
    }
    
	func showChannel(id: Int) {
		MainRouter.shared.show(screen: "channel", params: ["id": id], present: false)
	}
	
	func showAllChannels() {
		MainRouter.shared.show(screen: "category", params: ["filter" : ChannelsFilter.subscribed], present: false)
	}
    
    func set(category: String) {
        self.category = category
    }
    
    func update(index: Int, vm: SmallChannelViewModel) {
        self.channels[index] = vm
        self.delegate?.reloadChannels()
    }
    
    func updateEmptyMessage(hide: Bool) {
        self.hideEmptyMessage = hide
        self.delegate?.updateEmptyMessage()
    }
    
    func showSearch(text: String?) {
        MainRouter.shared.show(screen: "search", params: ["text" : text as Any], present: false)
    }
}
