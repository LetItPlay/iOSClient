//
//  FeedViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import SwipeCellKit
import Crashlytics

enum FeedType {
	case feed, popular
}

class FeedViewController: UIViewController, ChannelProtocol {
	
	var viewModel: FeedVMProtocol!
    var emitter: FeedEmitterProtocol!
    
    var previousCell: NewFeedTableViewCell?
    var alertBlurView: UIVisualEffectView!
    var alertLabel: UILabel!

    var channelsView: ChannelsCollectionView!
	let tableView: UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), style: .grouped)
    
	let emptyLabel: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.textAlignment = .center
		label.numberOfLines = 0
		label.text = "There are no tracks here yet. Subscribe to one of the channels first".localized
		return label
	}()

    let emptyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = AppFont.Title.section
        button.setTitle("Browse channels list".localized, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsetsMake(3, 12.5, 3, 12.5)
        return button
    }()
    
    var tappedSideButton = false
    
    convenience init(vm: FeedVMProtocol, emitter: FeedEmitterProtocol, channelsView: ChannelsCollectionView) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = vm
        self.viewModel.delegate = self
        
        self.emitter = emitter
        self.channelsView = channelsView
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.navigationBar.prefersLargeTitles = false
		self.navigationItem.largeTitleDisplayMode = .automatic
		
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        view.backgroundColor = UIColor.vaWhite
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
//        if self.viewModel.showChannels {
//            channelsView.delegate = self
//
//            tableView.snp.makeConstraints { (make) in
//                make.top.equalTo(channelsView.snp.bottom)
//                make.left.equalTo(0)
//                make.right.equalTo(0)
//                make.bottom.equalTo(0)
//                //            make.edges.equalTo(self.view)
//            }
//        }
//        else {
//            channelsView.isHidden = true
//            tableView.snp.makeConstraints { (make) in
//                make.edges.equalTo(self.view)
//            }
//        }
		
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.refreshControl = refreshControl
		tableView.separatorStyle = .none
		
		tableView.register(NewFeedTableViewCell.self, forCellReuseIdentifier: NewFeedTableViewCell.cellID)
		tableView.backgroundColor = .white
		tableView.backgroundView?.backgroundColor = .clear
		tableView.sectionIndexBackgroundColor = .clear

        self.view.backgroundColor = .white
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
		refreshControl.beginRefreshing()

		tableView.tableFooterView = UIView()
		
		self.view.addSubview(emptyLabel)
		emptyLabel.snp.makeConstraints { (make) in
			make.center.equalTo(self.view).inset(-40)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}

        self.view.addSubview(emptyButton)
        emptyButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
			make.height.equalTo(32)
            make.top.equalTo(emptyLabel.snp.bottom).inset(-51)
        }
        emptyButton.addTarget(self, action: #selector(showAllChannels), for: .touchUpInside)
        
		emptyLabel.isHidden = !self.viewModel.showEmptyMessage
        emptyButton.isHidden = !self.viewModel.showEmptyMessage
		
		self.tableView.refreshControl?.beginRefreshing()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        self.emitter.send(event: LifeCycleEvent.appear)
        self.channelsView.emitter?.send(event: LifeCycleEvent.appear)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emitter.send(event: LifeCycleEvent.disappear)
        self.channelsView.emitter?.send(event: LifeCycleEvent.disappear)
    }
    
    deinit {
        self.emitter.send(event: LifeCycleEvent.deinitialize)
        self.channelsView.emitter?.send(event: LifeCycleEvent.deinitialize)
    }
	
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {[weak self] in self?.tableView.refreshControl?.endRefreshing()})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
  func showAllChannels() {
      let vc = ChannelsBuilder.build(params: nil)
      self.navigationController?.pushViewController(vc, animated: true)
  }
    
  func showChannel(station: Station) {
      let vc = ChannelViewController(station: station)
      self.navigationController?.pushViewController(vc, animated: true)
  }

  @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == .began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath)
                if self.previousCell != nil,
                   self.previousCell != cell
                {
                    previousCell?.getInfo(toHide: true, animated: true)
                }
                if self.previousCell == cell
                {
                    previousCell = nil
                    AnalyticsEngine.sendEvent(event: .longTap(to: .hideInfo))
                    (cell as! NewFeedTableViewCell).getInfo(toHide: true, animated: true)
                }
                else
                {
                    previousCell = cell as? NewFeedTableViewCell
                    AnalyticsEngine.sendEvent(event: .longTap(to: .showInfo))
                    (cell as! NewFeedTableViewCell).getInfo(toHide: false, animated: true)
                }
            }
        }
    }
    
    func addTrack(toBegining: Bool, for indexPath: IndexPath)
    {
//        let audioTrack = self.presenter.tracks[indexPath.row].audioTrack()
//        AudioController.main.addToUserPlaylist(track: audioTrack, inBeginning: toBegining)
//
//        let cell = tableView.cellForRow(at: indexPath) as! NewFeedTableViewCell
//
//        UIView.animate(withDuration: 0.3, animations: {
//            cell.alertBlurView.alpha = 1
//        })
//
//        let when = DispatchTime.now() + 1
//        DispatchQueue.main.asyncAfter(deadline: when){
//            UIView.animate(withDuration: 0.3, animations:{
//                cell.alertBlurView.alpha = 0
//            })
//        }
    }
}

extension FeedViewController: FeedVMDelegate {
    func reload() {
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func updateTableState() {
        
    }
    
    func make(updates: [CollectionUpdate : [Int]]) {
        tableView.beginUpdates()
        for key in updates.keys {
            if let indexes = updates[key]?.map({IndexPath(row: $0, section: 0)}) {
                switch key {
                case .insert:
                    tableView.insertRows(at: indexes, with: UITableViewRowAnimation.automatic)
                case .delete:
                    tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.automatic)
                case .update:
                    tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.automatic)
                }
            }
        }
        tableView.endUpdates()
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tracks.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewFeedTableViewCell.cellID)
        return cell ?? UITableViewCell.init(frame: CGRect.zero)
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.emitter.send(event: FeedEvent.trackSelected(index: indexPath.item))
//        if self.type == .feed {
//            AnalyticsEngine.sendEvent(event: .feedCardSelected)
//        }
//        else {
//            AnalyticsEngine.sendEvent(event: .trendEvent(event: .cardTapped))
//        }
//        self.presenter.play(index: indexPath.item)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as? NewFeedTableViewCell
        //for swipes
//        cell?.delegate = self
        
        self.emitter.send(event: FeedEvent.showing(index: indexPath.item))
        
        let vm = self.viewModel.tracks[indexPath.item]
        cell?.fill(vm: vm)
        
        cell?.getInfo(toHide: true, animated: false)
        cell?.alertBlurView.alpha = 0
		
		cell?.onLike = { [weak self] track in
            self?.emitter.send(event: FeedEvent.trackSelected(index: indexPath.item))
		}
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let vm = self.viewModel.tracks[indexPath.item]
		return NewFeedTableViewCell.height(vm: vm, width: tableView.frame.width)
    }
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let vm = self.viewModel.tracks[indexPath.item]
        return NewFeedTableViewCell.height(vm: vm, width: tableView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.showChannels
        {
            return 121
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.showChannels
        {
			if channelsView == nil {
            	channelsView = ChannelsCollectionView()
			}
            channelsView.delegate = self
            return channelsView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension FeedViewController: SwipeTableViewCellDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var toBeginning: Bool!
        var image: UIImage!
        var addTo = ""
        if orientation == .left
        {
            image = UIImage(named: "topIcon")
            toBeginning = true
            addTo = "up"
        }
        else
        {
            image = UIImage(named: "downIcon")
            toBeginning = false
            addTo = "down"
        }
        let addToPlaylistAction = SwipeAction(style: .default, title: "Add \(addTo)\nthe\nplaylist", handler: { action, indexPath in
            self.addTrack(toBegining: toBeginning, for: indexPath)
        })
        addToPlaylistAction.image = image
        addToPlaylistAction.backgroundColor = .clear
        
        addToPlaylistAction.textColor = AppColor.Element.sideButtonColor
        addToPlaylistAction.font = AppFont.Title.big
        addToPlaylistAction.delegate = self
        
        return [addToPlaylistAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = SwipeExpansionStyle.selection
        options.transitionStyle = .border
        options.maximumButtonWidth = 300
        options.minimumButtonWidth = 150
        options.backgroundColor = .white
        
        return options
    }
}

extension FeedViewController: SwipeDelegate
{
    func buttonTapped()
    {
        tappedSideButton = true
    }
}
