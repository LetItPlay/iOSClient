//
//  DBModels.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 11/09/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RealmSwift

enum ObjectAbsorbedType: Int32 {
    case liked    = 0x01
    case favorite = 0x02
    case listened = 0x04
}

class AbsorbedInfo: Object {
    var objectId: Int   = 0
    var objectType: Int = 0 //0 - Station, 1 - Track
    var absorbed: Int32 = 0
}
