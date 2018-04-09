//
// Created by Aleksey Tyurnin on 05/04/2018.
// Copyright (c) 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

protocol PlaylistViewDelegate: class {

}

protocol PlayerViewDelegate: class {

}

protocol TrackInfoViewDelegate: class {

}

enum PlayerControlsStatus {
    case isPlaying, canForward, canBackward
}

class PlayingPlaylistViewModel {
    var tracks: [TrackViewModel] = []
    var name: String = ""
    var length: String = ""
    var count: String = ""
}

class PlayerViewModel {
    var track: TrackViewModel = TrackViewModel()
    var channel: SearchChannelViewModel?
    var currentTime: Float = 0.0
    var currentTimeState: (past: String, future: String) = (past: "", future: "")
    var status: [PlayerControlsStatus : Bool] = [.isPlaying : false, .canForward: false, .canBackward: false]
}