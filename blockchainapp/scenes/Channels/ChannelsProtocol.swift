//
//  ChannelsProtocol.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

typealias ChannelResult = ([Channel1]) -> Void

protocol ChannelsViewProtocol: class {
    func display(channels: [Channel1])
    func select(rows: [Int])
}

protocol ChannelsPresenterProtocol: class {
    func getData(onComplete: @escaping ChannelResult)
    func select(channel: Channel1)
}

protocol ChannelProtocol {
    func showChannel(channel: Channel1)
    func showAllChannels()
}
