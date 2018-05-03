//
//  PlaylistViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class PlaylistViewController: UIViewController {

	let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
	var tracks: [[AudioTrack]] = [[]]
	var currentIndex: IndexPath = IndexPath.invalid
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .white
		
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.font = AppFont.Title.big
        label.textColor = AppColor.Title.dark
        label.text = "Current playlist".localized
        
        let tracks = IconedLabel.init(type: .tracks)
        tracks.setData(data: Int64(self.tracks[1].count))
        
        let time = IconedLabel.init(type: .time)
        time.setData(data: Int64(self.tracks[1].map({$0.length}).reduce(0, {$0 + $1})))
        
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
		
		tableView.register(PlayerTableViewCell.self, forCellReuseIdentifier: PlayerTableViewCell.cellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PlaylistViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.tracks.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tracks[section].count
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contr = AudioController.main
		contr.make(command: .play(id: self.tracks[indexPath].id))
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PlayerTableViewCell.cellID, for: indexPath) as! PlayerTableViewCell
		let track = self.tracks[indexPath]
		cell.track = track
        
        cell.onOthers = {[weak self] in
            let othersViewController = OthersBuilder.build(params: ["controller" : self as Any, "track" : track]) as! OthersAlertController
            self?.present(othersViewController, animated: true, completion: nil)
        }
        
		let hideListens = indexPath == currentIndex
//		cell.dataLabels[.listens]?.isHidden = hideListens
		cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
//        cell.showOthersButton.isHidden = hideListens
        
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.tracks[indexPath]
		return Common.height(text: track.name, width: tableView.frame.width)
	}
}
