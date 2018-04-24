//
//  PlaylistViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class PlayingPlaylistViewController: UIViewController, PlayingPlaylistViewDelegate {

	let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
	var tracks: [[AudioTrack]] = [[]]
	var currentIndex: IndexPath = IndexPath.invalid
    
    let timeLabel = IconedLabel(type: .time)
    let trackLabel = IconedLabel(type: .tracks)
    let nameLabel = UILabel()
	
	var emitter: PlayingPlaylistEmitter!
	var vm: PlayingPlaylistViewModel!
	
	convenience init(emitter: PlayingPlaylistEmitter, vm: PlayingPlaylistViewModel) {
		self.init(nibName: nil, bundle: nil)
		self.vm = vm
        self.vm.delegate = self
		self.emitter = emitter
	}
	
	func update() {
		self.tableView.reloadData()
        self.trackLabel.set(text: self.vm.count)
        self.timeLabel.set(text: self.vm.length)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .white
		
        let view = UIView()
        view.backgroundColor = .white
        
        nameLabel.font = AppFont.Title.big
        nameLabel.textColor = AppColor.Title.dark
        nameLabel.text = "Current playlist".localized
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(3)
            make.left.equalToSuperview().inset(16)
        }
        
        view.addSubview(trackLabel)
        trackLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(nameLabel.snp.bottom).inset(-7)
        }
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(trackLabel.snp.right).inset(-8)
            make.centerY.equalTo(trackLabel)
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
        
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(60)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(73)
        }
        
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().inset(60)
            make.top.equalTo(view.snp.bottom)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		tableView.delegate = self
		tableView.dataSource = self
		
		self.tableView.separatorColor = self.tableView.backgroundColor
		
		tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PlayingPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.vm.tracks.count
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		let contr = AudioController.main
//		contr.make(command: .play(id: self.tracks[indexPath].id))
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SmallTrackTableViewCell.cellID, for: indexPath) as! SmallTrackTableViewCell
		let track = self.vm.tracks[indexPath.item]
		cell.fill(vm: track)

        cell.onOthers = {[weak self] in
            let othersViewController = OthersBuilder.build(params: ["controller" : self as Any, "track" : track]) as! OthersAlertController
            self?.present(othersViewController, animated: true, completion: nil)
        }
        
//		let hideListens = indexPath == currentIndex
////		cell.dataLabels[.listens]?.isHidden = hideListens
//		cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
////        cell.showOthersButton.isHidden = hideListens
        
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let track = self.vm.tracks[indexPath.item]
		return Common.height(text: track.name, width: tableView.frame.width)
	}
}
