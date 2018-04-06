import Foundation

protocol PlaylistModelDelegate: class {

}

protocol PlayerModelDelegate: class {

}

class PlayerModel: ModelProtocol {

    weak var playerDelegate: PlayerModelDelegate?
    weak var playlistDelegate: PlaylistModelDelegate?

    var playlistName: String = ""
    var tracks: [Track] = []
    var playingIndex: Int = -1


    func send(event: LifeCycleEvent) {

    }
}