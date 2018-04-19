import Foundation

class PlayingPlaylistEmitter: Emitter {
	weak var model: PlaylistEventHandler?
	
	convenience init(model: (PlaylistEventHandler & ModelProtocol)) {
		self.init(handler: model)
		self.model = model
	}
}
