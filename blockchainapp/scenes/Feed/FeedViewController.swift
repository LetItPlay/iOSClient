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
	
    let tableView: UITableView = UITableView()
    
    var previousCell: NewFeedTableViewCell?
    var alertBlurView: UIVisualEffectView!
    var alertLabel: UILabel!

    var channelsView: ChannelsCollectionView!
    var animatedChannels: Bool = true
    var previousOffsetY: CGFloat = 0
	let emptyLabel: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.textAlignment = .center
		label.numberOfLines = 0
		label.text = "There are no tracks here.\nPlease subscribe on one\nof the channels in Channel tab".localized
		return label
	}()
    
    convenience init(vm: FeedVMProtocol, emitter: FeedEmitterProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = vm
        self.viewModel.delegate = self
        
        self.emitter = emitter
        
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.navigationBar.prefersLargeTitles = false
		self.navigationItem.largeTitleDisplayMode = .automatic
		
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        view.backgroundColor = UIColor.vaWhite

        channelsView = ChannelsCollectionView.init(frame: self.view.frame)
        
        self.view.addSubview(channelsView)
        channelsView.snp.makeConstraints { (make) in
            make.top.equalTo((self.navigationController?.navigationBar.frame.origin.y)! + (self.navigationController?.navigationBar.frame.size.height)!)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(121)
        }
        
        self.view.addSubview(tableView)
        
        if self.viewModel.showChannels {
            channelsView.delegate = self
            
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(channelsView.snp.bottom)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                //            make.edges.equalTo(self.view)
            }
        }
        else {
            channelsView.isHidden = true
            tableView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.view)
            }
        }
		
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.refreshControl = refreshControl
		tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 72,
                                              right: 0)
		
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
			make.center.equalTo(self.view)
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
		}
		emptyLabel.isHidden = !self.viewModel.showEmptyMessage
		
		self.tableView.refreshControl?.beginRefreshing()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        self.emitter.send(event: LifeCycleEvent.appear)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emitter.send(event: LifeCycleEvent.disappear)
    }
    
    deinit {
        self.emitter.send(event: LifeCycleEvent.deinitialize)
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

  func showChannels(up: Bool)
  {
      if animatedChannels && self.viewModel.showChannels
      {
          if up, self.channelsView.frame.origin.y != -136
          {
              var tableFrame = self.tableView.frame
              tableFrame.size.height += self.channelsView.frame.height
              tableFrame.origin.y -= self.channelsView.frame.height
              animatedChannels = false
              var frame = self.channelsView.frame
              frame.origin.y -= 200
              UIView.animate(withDuration: 0.4, animations: {
                  self.channelsView.frame = frame
                  self.tableView.frame = tableFrame
              }, completion: { (value: Bool) in
                  self.animatedChannels = true
                  })
          }
          if !up, self.channelsView.frame.origin.y != 64
          {
              var tableFrame = self.tableView.frame
              tableFrame.size.height -= self.channelsView.frame.height
              tableFrame.origin.y += self.channelsView.frame.height
              animatedChannels = false
              var frame = self.channelsView.frame
              frame.origin.y += 200
              UIView.animate(withDuration: 0.4, animations: {
                  self.channelsView.frame = frame
                  self.tableView.frame = tableFrame
              }, completion: { (value: Bool) in
                  self.animatedChannels = true
              })
          }
      }
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
                    (cell as! NewFeedTableViewCell).getInfo(toHide: true, animated: true)
                }
                else
                {
                    previousCell = cell as? NewFeedTableViewCell
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
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as? NewFeedTableViewCell
        cell?.delegate = self
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if previousOffsetY + 60 < scrollView.contentOffset.y
        {
            previousOffsetY = scrollView.contentOffset.y
            self.showChannels(up: true)
        }
        if previousOffsetY - 60 > scrollView.contentOffset.y
        {
            previousOffsetY = scrollView.contentOffset.y
            self.showChannels(up: false)
        }
    }
}

extension FeedViewController: SwipeTableViewCellDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var begin: Bool!
        var image: UIImage!
        var addTo = ""
        if orientation == .left
        {
            image = UIImage(named: "topIcon")
            begin = true
            addTo = "up"
        }
        else
        {
            image = UIImage(named: "downIcon")
            begin = false
            addTo = "down"
        }
        let addToPlaylistAction = SwipeAction(style: .default, title: "Add \(addTo)\nthe\nplaylist", handler: { action, indexPath in
            self.addTrack(toBegining: begin, for: indexPath)
        })
        addToPlaylistAction.image = image
        addToPlaylistAction.backgroundColor = .clear
        
        addToPlaylistAction.textColor = AppColor.Element.sideButtonColor
        addToPlaylistAction.font = AppFont.Title.big
        
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
