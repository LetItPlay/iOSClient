import Foundation

protocol PlayingPlaylistEmitterProtocol {
	func itemSelected(index: Int)
    func showOthers(index: Int)
}

class PlayingPlaylistEmitter: Emitter, PlayingPlaylistEmitterProtocol {
	weak var model: PlaylistEventHandler?
	
	convenience init(model: (PlaylistEventHandler & ModelProtocol)) {
		self.init(handler: model)
		self.model = model
	}
	
	func itemSelected(index: Int) {
		self.model?.selected(index: index)
	}
    
    func showOthers(index: Int) {
        self.model?.showOthers(index: index)
    }
}
