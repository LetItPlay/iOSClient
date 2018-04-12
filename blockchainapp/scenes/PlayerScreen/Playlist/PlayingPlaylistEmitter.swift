import Foundation

class PlayingPlaylistEmitter: Emitter {
	weak var model: PlaylistEventHandler?
	
	convenience init(handler: (PlaylistEventHandler & ModelProtocol)) {
		self.init(handler: handler)
		self.model = handler
	}
}
