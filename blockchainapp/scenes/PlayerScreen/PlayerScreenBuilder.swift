import Foundation
import UIKit

class PlayerHandler {
    var model: (PlayerProtocol & PlaylistProtocol)
    var miniPlayer: MiniPlayerView!
    var playerVC: MainPlayerViewController!
    var main: PlayerViewController?

    init() {
        let player = AudioPlayer()
        let playerModel = PlayerModel(player: player)
        let playerVM = PlayerViewModel()
        playerModel.playerDelegate = playerVM
        let playerEmitter = PlayerEmitter(model: playerModel)
        self.playerVC = MainPlayerViewController(viewModel: playerVM, emitter: playerEmitter)

		let playlistVM = PlayingPlaylistViewModel()
		playerModel.playlistDelegate = playlistVM
		let playlistEmitter = PlayingPlaylistEmitter(handler: playerModel)
		let playlistVC = PlayingPlaylistViewController(emitter: playlistEmitter, vm: playlistVM)
		
        self.model = playerModel
        self.miniPlayer = MiniPlayerView()

        playerVC.miniPlayer = self.miniPlayer
    }
}
