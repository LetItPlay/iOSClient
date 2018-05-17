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
    var tableProvider: TableProvider!
    
    let emptyLabel = EmptyLabel(title: LocalizedStrings.EmptyMessage.noTracks)
            
    let clearButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(AppColor.Element.redBlur.withAlphaComponent(1), for: .normal)
        button.setTitle(LocalizedStrings.Playlists.clearAll, for: .normal)
        button.titleLabel?.font = AppFont.Button.mid
        button.titleLabel?.textAlignment = .right
        return button
    }()
    
    convenience init(vm: UserPlaylistVMProtocol, emitter: UserPlaylistEmitterProtocol)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = vm
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
        self.tableProvider = TableProvider(tableView: self.tableView, dataProvider: self, cellProvider: self)
        
        self.tableProvider.cellEvent = { (indexPath, event, data) in
            switch event {
            case "onSelected":
                self.emitter.send(event: UserPlaylistEvent.trackSelected(index: indexPath.row))
            case "onOthers":
                self.emitter.send(event: UserPlaylistEvent.showOthers(index: indexPath.row))
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
    
    func viewInitialize()
    {
        self.view.backgroundColor = UIColor.vaWhite
        
        self.navigationController?.navigationBar.addSubview(clearButton)
        clearButton.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.center)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        tableView.backgroundView?.backgroundColor = .clear
        tableView.sectionIndexBackgroundColor = .clear
        
//        tableView.delegate = self
//        tableView.dataSource = self
        
        self.tableView.contentInset.top = 44
        self.tableView.contentInset.bottom = 65
        
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        tableView.register(ChannelTrackCell.self, forCellReuseIdentifier: ChannelTrackCell.cellID)

        tableView.allowsMultipleSelectionDuringEditing = false
        
        clearButton.addTarget(self, action: #selector(clearPlaylist), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emitter.send(event: LifeCycleEvent.appear)
        
        self.clearButton.isHidden = self.viewModel.hideEmptyMessage
        
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.emitter.send(event: LifeCycleEvent.disappear)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clearPlaylist()
    {
        UserPlaylistManager.shared.clearPlaylist()
        self.emitter.send(event: UserPlaylistEvent.clearPlaylist)
        self.tableView.reloadData()
    }
}

extension UserPlaylistViewController: UserPlaylistVMDelegate
{
    func show(othersController: OthersAlertController) {
        self.present(othersController, animated: true, completion: nil)
    }
    
    func reload() {
        self.emptyLabel.isHidden = !self.viewModel.hideEmptyMessage
        self.clearButton.isHidden = self.viewModel.hideEmptyMessage
        self.navigationItem.rightBarButtonItem?.isEnabled = !self.viewModel.hideEmptyMessage
        self.tableView.reloadData()
    }
    
    func make(updates: [CollectionUpdate : [Int]]) {
//        tableView.beginUpdates()
        for key in updates.keys {
            if let indexes = updates[key]?.map({IndexPath(row: $0, section: 0)}) {
                switch key {
                case .insert:
                    tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                case .delete:
                    tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                case .update:
                    if indexes.count != 0 {
//                        tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                        tableView.reloadData()
                    }
                }
            }
        }
//        tableView.endUpdates()
    }

    func delete(index: Int) {
        tableView.deleteRows(at: [IndexPath.init(item: index, section: 0)], with: .automatic)
    }
}

extension UserPlaylistViewController: TableDataProvider, TableCellProvider {
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.tracks[indexPath.item]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return ChannelTrackCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        (cell as? SwipeTableViewCell)?.delegate = self
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.tracks.count
    }
}

//extension UserPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.tracks.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.emitter.send(event: UserPlaylistEvent.trackSelected(index: indexPath.row))
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTrackCell.cellID, for: indexPath) as! ChannelTrackCell
//        cell.delegate = self
//        cell.track = self.viewModel.tracks[indexPath.item]
//
//        cell.onOthers = {[weak self] in
//            self?.emitter?.send(event: UserPlaylistEvent.showOthers(index: indexPath.row))
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 107
//    }
//}

extension UserPlaylistViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: LocalizedStrings.SystemMessage.delete) { action, indexPath in
            self.emitter.send(event: .trackDelete(index: indexPath.item))
        }
        deleteAction.backgroundColor = .white
        
        deleteAction.frameForTitleLabel = CGRect(x: 8, y: 50, width: 150, height: 50)
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = SwipeExpansionStyle.selection
        options.transitionStyle = .border
        options.backgroundColor = .white
        
        let fromColor = AppColor.Element.redBlur.withAlphaComponent(0.9).cgColor
        let toColor = AppColor.Element.redBlur.withAlphaComponent(0).cgColor
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: (self.tableView.cellForRow(at: indexPath)?.frame.height)!)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [fromColor, toColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        gradientLayer.frame = frame
        gradientLayer.cornerRadius = 10
        
        options.showGradient = gradientLayer
        
        return options
    }
}

