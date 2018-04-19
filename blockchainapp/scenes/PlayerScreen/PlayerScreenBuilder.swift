import Foundation
import UIKit

class PlayerHandler {
    weak static var player: PlayerProtocol?
    weak static var playlist: PlaylistProtocol?
    var model: (PlayerProtocol & PlaylistProtocol)
    var miniPlayer: MiniPlayerView!
    var main: MainPlayerViewController!

    init() {
        let player = AudioPlayer()
        let playerModel = PlayerModel(player: player)
        let playerVM = PlayerViewModel()
        playerModel.playerDelegate = playerVM
        let playerEmitter = PlayerEmitter(model: playerModel)
        let playerVC = PlayerViewController(viewModel: playerVM, emitter: playerEmitter)

		let playlistVM = PlayingPlaylistViewModel()
		playerModel.playlistDelegate = playlistVM
		let playlistEmitter = PlayingPlaylistEmitter(model: playerModel)
		let playlistVC = PlayingPlaylistViewController(emitter: playlistEmitter, vm: playlistVM)
		
        self.model = playerModel
        self.miniPlayer = MiniPlayerView()
		self.miniPlayer.emitter = playerEmitter

        playerVC.miniPlayer = self.miniPlayer

        PlayerHandler.player = playerModel
        PlayerHandler.playlist = playerModel
		
		self.main = MainPlayerViewController(vcs: [playerVC, playlistVC])
    }
}
