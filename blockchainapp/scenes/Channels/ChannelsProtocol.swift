//
//  ChannelsProtocol.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

typealias ChannelResult = ([Channel]) -> Void

protocol ChannelsViewProtocol: class {
    func display(channels: [Channel])
    func select(rows: [Int])
}

protocol ChannelsPresenterProtocol: class {
    func getData(onComplete: @escaping ChannelResult)
    func select(channel: Channel)
}

protocol ChannelProtocol {
    func showChannel(channel: Channel)
    func showAllChannels()
}
