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

enum FeedType {
	case feed, popular
}

class FeedViewController: UIViewController, FeedViewProtocol, ChannelProtocol {
    
    var presenter: FeedPresenterProtocol!
    fileprivate var source = [Track]()
	var cellHeight: CGFloat = 343.0 + 24.0
    var previousCell: NewFeedTableViewCell?
    var alertBlurView: UIVisualEffectView!
    var alertLabel: UILabel!

	var type: FeedType = .feed
    var channelsView: ChannelsCollectionView!
    var animatedChannels: Bool = true
    var previousOffsetY: CGFloat = 0
	let tableView: UITableView = UITableView()
	let emptyLabel: UILabel = {
		let label = UILabel()
		label.font = AppFont.Title.big
		label.textColor = AppColor.Title.dark
		label.textAlignment = .center
		label.numberOfLines = 0
		label.text = "There are no tracks here.\nPlease subscribe on one\nof the channels in Channel tab".localized
		return label
	}()
	
	convenience init(type: FeedType) {
		self.init(nibName: nil, bundle: nil)
		
		self.type = type
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.navigationBar.prefersLargeTitles = false
		self.navigationItem.largeTitleDisplayMode = .automatic
		
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        presenter = FeedPresenter(view: self, orderByListens: self.type == .popular)
        
//        navigationController?.isNavigationBarHidden = true
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
        
        if self.type != .popular
        {
            channelsView.isHidden = true
            tableView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.view)
            }
        }
        else
        {
            channelsView.delegate = self
            
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(channelsView.snp.bottom)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                //            make.edges.equalTo(self.view)
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
		emptyLabel.isHidden = self.type == .popular
		
		presenter.getData { (tracks) in
			
		}
		self.tableView.refreshControl?.beginRefreshing()
        
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.cellHeight = self.view.frame.width - 16 * 2 + 24 // side margins
	}
	
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        presenter.getData { (tracks) in
			
        }
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {[weak self] in self?.tableView.refreshControl?.endRefreshing()})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func display() {
//        source = tracks
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
		if self.type == .feed {
			self.emptyLabel.isHidden = presenter.tracks.count != 0
		}
    }
	
	func reload(update: [Int], delete: [Int], insert: [Int]) {
//		UIView.setAnimationsEnabled(false)
//		tableView.beginUpdates()
//		if self.view.window != nil {
//			tableView.insertRows(at: insert.map({IndexPath(row: $0, section: 0)}), with: .none)
//			tableView.deleteRows(at: delete.map({IndexPath(row: $0, section: 0)}), with: .none)
//			tableView.reloadRows(at: update.map({IndexPath(row: $0, section: 0)}), with: .none)
//		} else {
			tableView.reloadData()
//		}
//		tableView.endUpdates()
		self.tableView.refreshControl?.endRefreshing()
//		UIView.setAnimationsEnabled(true)
		if self.type == .feed {
			self.emptyLabel.isHidden = presenter.tracks.count != 0
		}
	}
    
  func showAllChannels() {
      let vc = ChannelsBuilder.build()
      self.navigationController?.pushViewController(vc, animated: true)
  }
    
  func showChannel(station: Station) {
      let vc = ChannelViewController(station: station)
      self.navigationController?.pushViewController(vc, animated: true)
  }

  func showChannels(up: Bool)
  {
      if animatedChannels
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
        //TODO: adding channel to playlist
        if toBegining
        {

        }
        else
        {

        }

        let cell = tableView.cellForRow(at: indexPath) as! NewFeedTableViewCell

        UIView.animate(withDuration: 0.3, animations: {
            cell.alertBlurView.alpha = 1
        })

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            UIView.animate(withDuration: 0.3, animations:{
                cell.alertBlurView.alpha = 0
            })
        }
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.tracks.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewFeedTableViewCell.cellID)
		
        return cell ?? UITableViewCell.init(frame: CGRect.zero)
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.presenter.play(index: indexPath.item)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as? NewFeedTableViewCell
        cell?.delegate = self
		let track = self.presenter.tracks[indexPath.item]
		cell?.track = track
		cell?.set(isPlaying: indexPath.item == self.presenter.playingIndex)
        
        cell?.getInfo(toHide: true, animated: false)
        cell?.alertBlurView.alpha = 0
		
		cell?.onPlay = { [weak self] _ in
			let index = indexPath.item
			self?.presenter.play(index: index)
		}
		
		cell?.onLike = { [weak self] track in
			let index = indexPath.item
			self?.presenter.like(index: index)
		}
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.presenter.tracks[indexPath.item]
		return NewFeedTableViewCell.height(text: track.name, width: tableView.frame.width)
//		return self.cellHeight
    }
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let track = self.presenter.tracks[indexPath.item]
		return NewFeedTableViewCell.height(text: track.name, width: tableView.frame.width)
//		return self.cellHeight
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
