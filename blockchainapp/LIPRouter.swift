import Foundation
import DeepLinkKit
import RxSwift

class LIPRouter: DPLDeepLinkRouter {
	
	var tabController: MainTabViewController?
	
	let disposeBag = DisposeBag()
	
	override init() {
		super.init()
		
		self.register("channel/:channelID(\\d+)/tracks/:trackID(\\d+)") { [weak self] (link) in
			if let channelId = Int(link?.routeParameters["channelID"] as? String ?? "") {
				if let vc = ChannelBuilder.build(params: ["id": channelId]) {
					self?.tabController?.currentNavigationViewController?.pushViewController(vc, animated: true)
				}
				
				if let trackId = Int(link?.routeParameters["trackID"] as? String ?? "") {
					self?.playTrack(id: trackId)
				}
			}
		}
		
		self.register("search/:searchString") {[weak self] (link) in
			if let text = link?.routeParameters["searchString"] as? String {
				
			}
		}
		
		self.register("track/:trackID") {[unowned self] (link) in
			if let id = Int(link?.routeParameters["trackID"] as? String ?? "") {
				self.playTrack(id: id)
			}
		}
	}
	
	func playTrack(id: Int) {
		RequestManager.shared.track(id: id).subscribe({ (event) in
			switch event {
			case .next(let track):
				AudioController.main.loadPlaylist(playlist: ("Pushed track \(id)", [track.audioTrack()]), playId: id)
				self.tabController?.showPlaylist()
			default:
				break
			}
		}).disposed(by: self.disposeBag)
	}
}


