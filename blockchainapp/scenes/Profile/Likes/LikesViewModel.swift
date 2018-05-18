//
//  LikesViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 12.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import RxSwift

protocol LikesVMProtocol: TrackHandlingViewModelProtocol {
    var length: String {get set}
  
    var likesDelegate: LikesVMDelegate? {get set}
}

protocol LikesVMDelegate: class {
}

class LikesViewModel: TrackHandlingViewModel, LikesVMProtocol, LikesModelDelegate {
    weak var likesDelegate: LikesVMDelegate?
}
