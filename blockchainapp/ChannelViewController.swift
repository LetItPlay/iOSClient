//
//  ChannelViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 27/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class ChannelViewController: UIViewController, ChannelPresenterDelegate {

	let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .grouped)
	
	weak var station: Station!
	var presenter: ChannelPresenter!
	var header: ChannelHeaderView = ChannelHeaderView()
	var currentIndex: Int = -1
	
	init(station: Station) {
		super.init(nibName: nil, bundle: nil)
		
		self.station = station
		self.presenter = ChannelPresenter(station: station)
		self.presenter.view = self
	}
	
	func followUpdate() {
		self.header.followButton.isSelected = SubscribeManager.shared.stations.contains(self.presenter.station.id)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Channel"
		
		self.view.backgroundColor = UIColor.white
		self.tableView.backgroundColor = .white
		
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		self.header = ChannelHeaderView(frame: self.view.frame)
		header.translatesAutoresizingMaskIntoConstraints = false
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
		self.header.followButton.isSelected = SubscribeManager.shared.stations.contains(self.presenter.station.id)
		
		self.header.followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
		
		self.tableView.tableHeaderView = self.header
    }
	
	func followPressed() {
		self.presenter.followPressed()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.header.snp.makeConstraints { (make) in
//			make.height.equalTo(height)
			make.width.equalTo(self.view.frame.width)
		}
		
		let height = self.header.fill(station: self.station, width: self.view.frame.width)
		self.header.frame.size.height = height
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func update() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
}

extension ChannelViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.presenter.tracks.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.presenter.tracks[section].count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Recent tracks"
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contr = AudioController.main
		contr.loadPlaylist(playlist: ("Channel\(self.station.id)", self.presenter.tracks[indexPath.section]))
		contr.setCurrentTrack(index: indexPath.item)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath) as! SmallTrackTableViewCell
		let track = self.presenter.tracks[indexPath.section][indexPath.item]
		cell.track = track
		let hideListens = indexPath.item == self.currentIndex
		cell.dataLabels[.listens]?.isHidden = hideListens
		cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
		return cell
	}
}
