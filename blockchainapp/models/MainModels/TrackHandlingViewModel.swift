//
//  TrackHandlingViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 17.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol TrackHandlingViewModelDelegate: class {
    func reload(cells: [CollectionUpdate: [Int]]?)
    func reload()
    func reloadAppearence()
}

protocol TrackHandlingViewModelProtocol {
    var delegate: TrackHandlingViewModelDelegate? {get set}
    var data: [TrackViewModel] {get set}
    var showEmpty: Bool {get set}
}

class TrackHandlingViewModel: TrackHandlingModelDelegate, TrackHandlingViewModelProtocol {
    
    weak var delegate: TrackHandlingViewModelDelegate?
    
    var data: [TrackViewModel] = []
//    var title: String = LocalizedStrings.SystemMessage.defaultMessage
    var showEmpty: Bool = false
    var needUpload: Bool = true
    
    func update(tracks: [Int : TrackViewModel]) {
        for tuple in tracks {
            self.data[tuple.key] = tuple.value
        }
        self.delegate?.reload(cells: [.update: Array<Int>(tracks.keys)])
    }
    
    func show(tracks: [TrackViewModel], isContinue: Bool) {
        var cells: [CollectionUpdate: [Int]]?
        if isContinue {
            let insertStart = self.data.count
            self.data += tracks
            cells = [.insert: Array<Int>(insertStart..<self.data.count)]
            self.delegate?.reload(cells: cells)
        } else {
            self.data = tracks
            self.delegate?.reload()
        }
    }
    
    func empty(show: Bool) {
        self.showEmpty = show
        self.delegate?.reloadAppearence()
    }
    
    func noDataLeft() {
        self.needUpload = false
    }
    
    func showChannel(id: Int) {
        MainRouter.shared.show(screen: "channel", params: ["id" : id], present: false)
    }
    
    func showInfo(track: ShareInfo) {
        MainRouter.shared.showOthers(shareInfo: track)
    }
}
