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
		
		self.title = "Channel".localized
		
		self.view.backgroundColor = UIColor.white
		self.tableView.backgroundColor = .white
		self.tableView.separatorColor = self.tableView.backgroundColor
		
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		self.header = ChannelHeaderView(frame: self.view.frame)
		header.translatesAutoresizingMaskIntoConstraints = false
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.register(ChannelTrackCell.self, forCellReuseIdentifier: ChannelTrackCell.cellID)
		self.header.followButton.isSelected = SubscribeManager.shared.stations.contains(self.presenter.station.id)
		
		self.header.followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
		
		self.tableView.tableHeaderView = self.header
    }
	
	@objc func followPressed() {
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
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .white
		
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.text = "Recent added".localized
		
		view.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(12)
			make.left.equalToSuperview().inset(16)
		}
		
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 53
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contr = AudioController.main
		contr.loadPlaylist(playlist: ("Channel".localized + " \(self.station.id)", self.presenter.tracks[indexPath.section].map({$0.audioTrack()})))
		contr.setCurrentTrack(index: indexPath.item)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTrackCell.cellID, for: indexPath) as! ChannelTrackCell
		let track = self.presenter.tracks[indexPath.section][indexPath.item]
		cell.track = track
		let hideListens = indexPath.item == self.currentIndex
		cell.dataLabels[.listens]?.isHidden = hideListens
		cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.presenter.tracks[indexPath.section][indexPath.item]
		return ChannelTrackCell.height(text: track.name, width: tableView.frame.width)
	}
}
