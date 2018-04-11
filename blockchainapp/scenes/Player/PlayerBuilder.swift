import Foundation
import UIKit

class PlayerHandler {
    var miniPlayer: MiniPlayerView!
    var main: PlayerViewController!

    init() {
        let player = AudioPlayer()
        let playerModel = PlayerModel(player: player)
        let playerVM = PlayerViewModel()
        let emitter = PlayerEmitter(handler: playerModel)
        let playerVC = MainPlayerViewController(viewModel: playerVM, emitter: emitter)

        self.main = PlayerViewController()
        self.miniPlayer = MiniPlayerView()

        playerVC.miniPlayer = self.miniPlayer
    }
}