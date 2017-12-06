//
//  PlaylistView.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 06/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class PlaylistView: UIView {
	
	let tableView: UITableView = UITableView.init(frame: CGRect.zero)
	var tracks: [Track] = []
	
	convenience init() {
		self.init(frame: CGRect.zero)
		
		self.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.contentInset.top = 67.0
		
		tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
	}

}

extension PlaylistView: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tracks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath)
		let track = tracks[indexPath.item]
		return cell
	}
}
