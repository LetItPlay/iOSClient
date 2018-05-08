//
//  ChannelCategory.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 03.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChannelCategory {
    var id: Int = 0
    var name: String = ""
    var channels: [Channel] = []
    
    init?(json: JSON) {
        if let id = json["id"].int,
           let name = json["name"].string {
            self.id = id
            self.name = name
            
            guard let channels = json["stations"].array?.map({Channel(json: $0)!}) else {
                self.channels = []
                return
            }
            
            self.channels = channels
            
            return
        }
        
        return nil
    }
}
