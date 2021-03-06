//
//  PlaylistView.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 06/12/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class PlaylistView: UIView {
	
	let tableView: UITableView = UITableView.init(frame: .zero, style: .grouped)
	var tracks: [[AudioTrack]] = [[]]
	var currentIndex: IndexPath = IndexPath.invalid
	
	convenience init() {
		self.init(frame: CGRect.zero)
		
		self.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		tableView.delegate = self
		tableView.dataSource = self
		
		self.tableView.separatorColor = self.tableView.backgroundColor

		tableView.register(PlayerTableViewCell.self, forCellReuseIdentifier: PlayerTableViewCell.cellID)
	}

}

extension PlaylistView: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.tracks.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tracks[section].count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if self.tracks[section].count == 0 {
			return nil
		}
		
		let view = UIView()
		view.backgroundColor = .white
		
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.text = "Current playlist".localized
		
		let tracks = IconedLabel.init(type: .tracks)
		tracks.setData(data: Int64(self.tracks[section].count))
		
		let time = IconedLabel.init(type: .time)
		time.setData(data: Int64(self.tracks[section].map({$0.length}).reduce(0, {$0 + $1})))
		
		view.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(3)
			make.left.equalToSuperview().inset(16)
		}
		
		view.addSubview(tracks)
		tracks.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalTo(label.snp.bottom).inset(-7)
		}
		
		view.addSubview(time)
		time.snp.makeConstraints { (make) in
			make.left.equalTo(tracks.snp.right).inset(-8)
			make.centerY.equalTo(tracks)
		}
		
		let line = UIView()
		line.backgroundColor = AppColor.Element.redBlur
		line.layer.cornerRadius = 1
		line.layer.masksToBounds = true
		
		view.addSubview(line)
		line.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.bottom.equalToSuperview()
			make.height.equalTo(2)
		}
		
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if self.tracks[section].count == 0 {
			return 0.1
		}
		return 73
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contr = AudioController.main
		contr.make(command: .play(id: self.tracks[indexPath].id))
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PlayerTableViewCell.cellID, for: indexPath) as! PlayerTableViewCell
		let track = self.tracks[indexPath]
		cell.track = track
		let hideListens = indexPath == currentIndex
		cell.dataLabels[.listens]?.isHidden = hideListens
		cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.tracks[indexPath]
		return SmallTrackTableViewCell.height(text: track.name, width: tableView.frame.width)
	}
}
