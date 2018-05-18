//
//  PlaylistViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit

class PlayingPlaylistViewController: UIViewController {

	let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
    var tableProvider: TableProvider!
    
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
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = {(indexPath, event, data) in
            switch event {
            case "onSelected":
                self.emitter.itemSelected(index: indexPath.item)
            case "onOthers":
                self.emitter.showOthers(index: indexPath.row)
            default:
                break
            }
        }
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .white
		
        let view = UIView()
        view.backgroundColor = .white
        
        nameLabel.font = AppFont.Title.big
        nameLabel.textColor = AppColor.Title.dark
        nameLabel.text = LocalizedStrings.Playlists.currentPlaylist
        
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
            make.top.equalTo(view.snp.bottom)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		self.tableView.separatorColor = self.tableView.backgroundColor
		
		tableView.register(SmallTrackTableViewCell.self, forCellReuseIdentifier: SmallTrackTableViewCell.cellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PlayingPlaylistViewController: TableDataProvider, TableCellProvider {
    func data(indexPath: IndexPath) -> Any {
        return self.vm.tracks[indexPath.item]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return SmallTrackTableViewCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.vm.tracks.count
    }
}

extension PlayingPlaylistViewController: PlayingPlaylistViewDelegate {
    func update() {
        self.tableView.reloadData()
    }
    
    func reload(index: Int) {
        tableView.reloadData()
    }
    
    func updateTitles() {
        self.trackLabel.set(text: self.vm.count)
        self.timeLabel.set(text: self.vm.length)
        self.nameLabel.text = self.vm.name
    }
}
