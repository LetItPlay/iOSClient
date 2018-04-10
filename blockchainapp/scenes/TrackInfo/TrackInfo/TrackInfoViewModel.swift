//
//  TrackInfoViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 20.03.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

enum TrackInfoResultUpdate {
    case track, channel, channelSubscription
}

protocol TrackInfoVMDelegate: class {
    func update(data: TrackInfoResultUpdate)
}

class TrackInfoViewModel: TrackInfoModelDelegate {
    
    var track: TrackViewModel!
    var channel: SearchChannelViewModel!
    var trackDescription: NSMutableAttributedString!
    
    weak var delegate: TrackInfoVMDelegate?
    
    func reload(track: TrackViewModel) {
        DispatchQueue.main.async {
            self.track = track
            
            do {
                var dict: NSDictionary? = [NSAttributedStringKey.font : AppFont.Title.info]
                self.trackDescription = try NSMutableAttributedString(data: track.description.data(using: .utf16)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: &dict)
                self.trackDescription.addAttribute(NSAttributedStringKey.font, value: AppFont.Title.info, range: NSRange(location: 0, length: self.trackDescription.length))
            } catch (let error) {
                print(error)
            }
            
            self.delegate?.update(data: .track)
        }
    }
    
    func reload(channel: SearchChannelViewModel) {
        self.channel = channel
        
        delegate?.update(data: .channel)
    }
    
    func followUpdate(isSubscribed: Bool) {
        self.channel?.isSubscribed = isSubscribed
        self.delegate?.update(data: .channelSubscription)
    }
    
    func showChannel(id: Int) {
        MainRouter.shared.show(screen: "channel", params: ["id" : id], present: false)
        MainRouter.shared.hidePlayer()
    }
}
