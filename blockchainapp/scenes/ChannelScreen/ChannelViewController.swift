//
//  ChannelViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 27/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class ChannelViewController: UIViewController, ChannelVMDelegate {

	let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .grouped)
	
//    weak var station: Station!
    
    var viewModel: ChannelVMProtocol!
    var emitter: ChannelEmitterProtocol!
//    var presenter: ChannelPresenter!
	var header: ChannelHeaderView = ChannelHeaderView()
	var currentIndex: Int = -1
	
    init(viewModel: ChannelVMProtocol, emitter: ChannelEmitterProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.emitter = emitter
    }
	
    func followUpdate() {
         //SubscribeManager.shared.stations.contains(self.presenter.station.id)
    }
    
    func reloadTracks() {
        self.tableView.reloadData()
    }
    
    func updateSubscription() {
        self.header.followButton.isSelected = self.viewModel.isSubscribed
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
        
        tableView.contentInset.bottom = 70
		
		self.header = ChannelHeaderView(frame: self.view.frame)
		header.translatesAutoresizingMaskIntoConstraints = false
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.register(ChannelTrackCell.self, forCellReuseIdentifier: ChannelTrackCell.cellID)
		self.header.followButton.isSelected = self.viewModel.isSubscribed //SubscribeManager.shared.stations.contains(self.presenter.station.id)
		
		self.header.followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
		
		self.tableView.tableHeaderView = self.header
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
	
	@objc func followPressed() {
//        self.presenter.followPressed()
        self.emitter.send(event: ChannelEvent.followPressed)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.header.snp.makeConstraints { (make) in
//            make.height.equalTo(height)
			make.width.equalTo(self.view.frame.width)
		}
		
        let height = self.header.fill(channel: self.viewModel.channel!, width: self.view.frame.width)
		self.header.frame.size.height = height
        self.emitter.send(event: LifeCycleEvent.appear)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func update() {
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
    }
    
    func make(updates: [CollectionUpdate : [Int]]) {
        tableView.beginUpdates()
        for key in updates.keys {
            if let indexes = updates[key]?.map({IndexPath(row: $0, section: 0)}) {
                switch key {
                case .insert:
                    tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                case .delete:
                    tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                case .update:
                    tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                }
            }
        }
        tableView.endUpdates()
    }
}

extension ChannelViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel.tracks.count
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
//        let contr = AudioController.main
//        contr.loadPlaylist(playlist: ("Channel".localized + " \(self.station.id)", self.presenter.tracks[indexPath.section].map({$0.audioTrack()})),
//                           playId: self.presenter.tracks[indexPath.section][indexPath.item].audiotrackId())
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTrackCell.cellID, for: indexPath) as! ChannelTrackCell
		let track = self.viewModel.tracks[indexPath.item]
		cell.track = track
		let hideListens = indexPath.item == self.currentIndex
		cell.dataLabels[.listens]?.isHidden = hideListens
		cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.viewModel.tracks[indexPath.item]
		return ChannelTrackCell.height(text: track.name, width: tableView.frame.width)
	}
}
