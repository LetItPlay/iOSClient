//
//  PlaylistsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SwipeCellKit

class UserPlaylistViewController: UIViewController {
    
    var viewModel: UserPlaylistVMProtocol!
    var emitter: UserPlaylistEmitterProtocol!

    let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
    var tracks: [[AudioTrack]] = [[]]
    var currentIndex: IndexPath = IndexPath.invalid
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.sectionNotBold
        label.textColor = AppColor.Element.emptyMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "There are no tracks".localized
        return label
    }()
    
    convenience init(vm: UserPlaylistVMProtocol, emitter: UserPlaylistEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = vm
        self.viewModel.delegate = self
        
        self.emitter = emitter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = UIColor.vaWhite
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Clear all".localized, style: .plain, target: self, action: #selector(clearPlaylist))
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(60)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.center)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        tableView.backgroundView?.backgroundColor = .clear
        tableView.sectionIndexBackgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.contentInset.bottom = 65
        
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        tableView.register(ChannelTrackCell.self, forCellReuseIdentifier: ChannelTrackCell.cellID)

        tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emitter.send(event: LifeCycleEvent.appear)
        
        self.tableView.reloadData()
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.emitter.send(event: LifeCycleEvent.disappear)
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clearPlaylist()
    {
        UserPlaylistManager.shared.clearPlaylist()
        self.emitter.send(event: PlaylistEvent.clearPlaylist)
        self.tableView.reloadData()
    }
}

extension UserPlaylistViewController: UserPlaylistVMDelegate
{
    
    func reload() {
        self.emptyLabel.isHidden = !self.viewModel.hideEmptyMessage
        self.navigationItem.rightBarButtonItem?.isEnabled = !self.viewModel.hideEmptyMessage
        self.tableView.reloadData()
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
                    if indexes.count != 0 {
                        tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                        //                        tableView.reloadData()
                    }
                }
            }
        }
        tableView.endUpdates()
    }

    func delete(index: Int) {
        tableView.deleteRows(at: [IndexPath.init(item: index, section: 0)], with: .automatic)
    }
}

extension UserPlaylistViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tracks.count
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.emitter.send(event: .trackDelete(index: indexPath.item))
        }
//        deleteAction.backgroundColor = .white
//        deleteAction.textColor = AppColor.Element.tomato

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.tracks.count == 0 {
            return nil
        }
        
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.font = AppFont.Title.big
        label.textColor = AppColor.Title.dark
        label.numberOfLines = 1
        label.text = "My playlist".localized
        
        let tracks = IconedLabel.init(type: .tracks)
        tracks.setData(data: Int64(UserPlaylistManager.shared.tracks.count))
        
        let time = IconedLabel.init(type: .time)
        time.setData(data: Int64(UserPlaylistManager.shared.tracks.map({$0.length}).reduce(0, {$0 + $1})))
        
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(3)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
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
        if UserPlaylistManager.shared.tracks.count == 0 {
            return 0.1
        }
        return 73
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.emitter.send(event: PlaylistEvent.trackSelected(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: PlayerTableViewCell.cellID, for: indexPath) as! PlayerTableViewCell
//        let track = UserPlaylistManager.shared.tracks[indexPath.row]
//        cell.track = track
//        let hideListens = indexPath == currentIndex
//        //        cell.dataLabels[.listens]?.isHidden = hideListens
//        cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTrackCell.cellID, for: indexPath) as! ChannelTrackCell
        cell.delegate = self
        cell.track = self.viewModel.tracks[indexPath.item]
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let track = UserPlaylistManager.shared.tracks[indexPath.row]
        return Common.height(text: track.name, width: tableView.frame.width)
    }
}

