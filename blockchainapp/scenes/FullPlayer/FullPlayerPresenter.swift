//
//  FullPlayerPresenter.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 19/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

class FullPlayerPresenter: FullPlayerPresenterProtocol {
    weak var view: FullPlayerViewProtocol?
    
    var subManager = SubscribeManager.shared
    
    var token: NotificationToken?
    
    init(view: FullPlayerViewProtocol) {
        self.view = view
        fetch()
    }
    
    func fetch() {
        if let trackStat = AppManager.shared.audioManager.currentItemId,
            let stringId = trackStat.split(separator: "_").first,
            let id = Int(stringId) {
            
            let realm = try! Realm()
            if let ob = realm.object(ofType: Track.self, forPrimaryKey: id) {
                view?.display(name: ob.name,
                              station: ob.findStationName() ?? "",
                              image: ob.image.buildImageURL())
            }
        }
    }
}
