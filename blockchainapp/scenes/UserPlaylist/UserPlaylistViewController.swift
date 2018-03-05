//
//  PlaylistsViewController.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 05.03.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class UserPlaylistViewController: UIViewController {
    
    var viewModel: UserPlaylistVMProtocol!
    var emitter: UserPlaylistEmitterProtocol!

    let tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
    var tracks: [[AudioTrack]] = [[]]
    var currentIndex: IndexPath = IndexPath.invalid
    
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
    }
    
    func viewInitialize()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "clear".localized, style: .plain, target: self, action: #selector(clearPlaylist))
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(60)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        tableView.register(PlayerTableViewCell.self, forCellReuseIdentifier: PlayerTableViewCell.cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        self.tableView.reloadData()
    }
}

extension UserPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserPlaylistManager.shared.tracks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if UserPlaylistManager.shared.tracks.count == 0 {
            return nil
        }
        
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.font = AppFont.Title.big
        label.textColor = AppColor.Title.dark
        label.numberOfLines = 1
        label.text = "User playlist".localized
        
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
        
//        let contr = AudioController.main
//        contr.make(command: .play(id: UserPlaylistManager.shared.tracks[indexPath.row].id))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayerTableViewCell.cellID, for: indexPath) as! PlayerTableViewCell
        let track = UserPlaylistManager.shared.tracks[indexPath.row]
        cell.track = track
        let hideListens = indexPath == currentIndex
        //        cell.dataLabels[.listens]?.isHidden = hideListens
        cell.dataLabels[.playingIndicator]?.isHidden = !hideListens
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let track = UserPlaylistManager.shared.tracks[indexPath.row]
        return Common.height(text: track.name, width: tableView.frame.width)
    }
}

extension UserPlaylistViewController: UserPlaylistVMDelegate
{
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
}
