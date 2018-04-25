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
        
        let model = TrackInfoModel(trackId: -1)
        let vm = TrackInfoViewModel()
        let emitter = TrackInfoEmitter.init(model: model)
        
        model.delegate = vm
        emitter.model = model
        
        let view = TrackInfoHeaderView(emitter: emitter, viewModel: vm)
        let vc = TrackInfoViewController(view: view)
        
        playerModel.trackInfoDelegate = model
        
        let panelEmitter = MainPlayerBottomIconsEmitter(model: playerModel)
        let bottomPanel = MainPlayerBottomIconsView(vm: playerVM, emitter: panelEmitter)
        
        self.main = MainPlayerViewController.init(vcs: [vc, playerVC, playlistVC], defaultIndex: 1, bottom: bottomPanel)
		self.main.modalPresentationStyle = .overFullScreen
    }
}
