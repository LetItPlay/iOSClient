//
//  ChannelsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 23.04.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {
    
    var channelsView: ChannelsCollectionView!
    
    convenience init(channelsView: ChannelsCollectionView) {//vm: FeedVMProtocol, emitter: FeedEmitterProtocol, channelsView: ChannelsCollectionView) {
        self.init(nibName: nil, bundle: nil)
//        self.viewModel = vm
//        self.viewModel.delegate = self
//
//        self.emitter = emitter
        
        self.channelsView = channelsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
    }
    
    func viewInitialize() {
        
    }
}
