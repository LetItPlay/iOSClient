import Foundation

protocol PlayingPlaylistEmitterProtocol {
	func itemSelected(index: Int)
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
}
