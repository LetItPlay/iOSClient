//
//  SmallTrackViewModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 13.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit

class SmallTrackViewModel {
    var trackViewModel: TrackViewModel!
    
    var iconUrl: URL? = nil
    var trackName: NSAttributedString? = nil
    var channelName: String = ""
    var time: String = ""
    var listens: String = ""
    var length: String = ""
    
    init(track: TrackViewModel)
    {
        self.trackViewModel = track
        
        self.iconUrl = track.imageURL
        self.trackName = self.trackText(text: track.name)
        
        self.channelName = track.author
        self.time = track.dateString
        self.listens = track.listensCount
        self.length = track.length
    }
    
    func trackText(text: String) -> NSAttributedString {
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = .byWordWrapping
        para.minimumLineHeight = 22
        para.maximumLineHeight = 22
        return NSAttributedString.init(string: text, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .paragraphStyle: para])
    }
}
