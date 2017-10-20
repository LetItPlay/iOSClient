//
//  FullPlayerProtocols.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 19/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol FullPlayerViewProtocol: class {
    func display(name: String, station: String, image: URL?)
}

protocol FullPlayerPresenterProtocol: class {
    func fetch()
}
