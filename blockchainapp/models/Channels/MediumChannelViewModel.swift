//
//  MediumChannelViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 14.02.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

class MediumChannelViewModel: SmallChannelViewModel {
    var name: String = ""
    var subscriptionCount: String = ""
    var tracksCount: String = ""
    var tags: [String] = []
    var isSubscribed: Bool = false
    var isHidden: Bool = false
    
    override init(channel: Channel) {
        super.init(channel: channel)
        
        self.name = channel.name
        self.subscriptionCount = Int64(channel.subscriptionCount).formatAmount()
        self.tracksCount = Int64(channel.trackCount).formatAmount()
        self.tags = channel.tags
        self.isSubscribed = channel.isSubscribed
        self.isHidden = channel.isHidden
    }
    
    func getMainButtonTitle() -> String {
        if self.isHidden {
            return LocalizedStrings.Button.show
        } else {
            return self.isSubscribed ? LocalizedStrings.Button.following : LocalizedStrings.Button.follow
        }
    }
}
