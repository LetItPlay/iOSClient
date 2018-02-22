//
//  ChannelsProtocol.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

typealias StationResult = ([Station1]) -> Void

protocol ChannelsViewProtocol: class {
    func display(channels: [Station1])
    func select(rows: [Int])
}

protocol ChannelsPresenterProtocol: class {
    func getData(onComplete: @escaping StationResult)
    func select(station: Station1)
}

protocol ChannelProtocol {
    func showChannel(station: Station1)
    func showAllChannels()
}
