//
//  FeedViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SwiftyAudioManager

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var listeningLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    let audioManager = AppManager.shared.audioManager
    
    public var onPlay: ((String) -> Void)?
    public var onLike: ((Int) -> Void)?
    public var onComment: ((Track) -> Void)?
    public var onMenu: ((Track) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 6
        
        contentView.backgroundColor = .clear
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset  = CGSize(width: 0, height: 2)
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 20
        
        nameLabel.font = UIFont(name: ".SFUIText-Bold", size: 14)
        nameLabel.textColor = UIColor.vaCharcoalGrey
        
        likesLabel.font     = UIFont(name: ".SFUIText-Medium", size: 12)
        listeningLabel.font = UIFont(name: ".SFUIText-Medium", size: 12)
        timeLabel.font      = UIFont(name: ".SFUIText-Bold", size: 12)
        
        likesLabel.textColor     = UIColor.vaCharcoalGrey
        listeningLabel.textColor = UIColor.vaCharcoalGrey
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerPaused(_:)),
                                               name: AudioManagerNotificationName.paused.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerStartPlaying(_:)),
                                               name: AudioManagerNotificationName.startPlaying.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerPaused(_:)),
                                               name: AudioManagerNotificationName.endPlaying.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerStartPlaying(_:)),
                                               name: AudioManagerNotificationName.resumed.notification,
                                               object: audioManager)
    }
    
    // MARK: - AudioManager events
    @objc func audioManagerStartPlaying(_ notification: Notification) {
        playButton.isSelected = audioManager.currentItemId == track?.uniqString()
    }
    
    @objc func audioManagerPaused(_ notification: Notification) {
        playButton.isSelected = false
    }
    
    class func recommendedHeight() -> CGFloat {
        return 192
    }
    
    weak var track: Track? = nil {
        didSet {
            nameLabel.text = track?.name
            
            if let iconUrl = track?.findChannelImage() {
                iconImageView.sd_setImage(with: iconUrl)
            } else {
                iconImageView.image = nil
            }
            
            if let iconUrl = track?.image.buildImageURL() {
                mainImageView.sd_setImage(with: iconUrl)
            } else {
                mainImageView.image = nil
            }
            
            likesLabel.text = "\(track?.likeCount ?? 0) \(NSLocalizedString("likes", comment: ""))"
            listeningLabel.text = "\(track?.listenCount ?? 0) \(NSLocalizedString("listening", comment: ""))"
            
            likeButton.isSelected = LikeManager.shared.hasObject(id: track?.id ?? 0)
            playButton.isSelected = audioManager.isPlaying && audioManager.currentItemId == track?.uniqString()
            
            let maxTime = track?.audiofile?.lengthSeconds ?? 0
            timeLabel.text = maxTime.formatTime()//String(format:"%02i:%02i", Int(maxTime) / 60 % 60, Int(maxTime) % 60)
        }
    }
    
    // MARK: - buttons
    
    @IBAction func playPressed(_ sender: Any) {
        if track != nil {
            onPlay?(track!.uniqString())
        }
    }
    
    @IBAction func likePressed(_ sender: Any) {
        likeButton.isSelected = !likeButton.isSelected
        if track != nil {
            onLike?(track!.id)
        }
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if track != nil {
            onMenu?(track!)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class FeedViewController: UITableViewController, FeedViewProtocol {
    
    var presenter: FeedPresenterProtocol!
    fileprivate var source = [Track]()
	var cellHeight: CGFloat = 343.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        presenter = FeedPresenter(view: self, orderByListens: navigationController?.title == "42")
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.vaWhite

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.refreshControl = refreshControl
        
        tableView.contentInset = UIEdgeInsets(top: 18,
                                              left: 0,
                                              bottom: 72,
                                              right: 0)
		
		tableView.register(NewFeedTableViewCell.self, forCellReuseIdentifier: NewFeedTableViewCell.cellID)
		tableView.backgroundColor = .white
		tableView.backgroundView?.backgroundColor = .white
		tableView.sectionIndexBackgroundColor = .white
		tableView.allowsSelection = false
		refreshControl?.beginRefreshing()
        presenter.getData { (tracks) in

        }
		
		self.cellHeight = self.tableView.frame.width - 16 * 2 // side margins
    }
	
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        presenter.getData { (tracks) in
			
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func display(tracks: [Track], deletions: [Int], insertions: [Int], modifications: [Int]) {
        source = tracks
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

}

extension FeedViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewFeedTableViewCell.cellID)
		
        return cell ?? UITableViewCell.init(frame: CGRect.zero)
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as? NewFeedTableViewCell
		cell?.track = source[indexPath.section]
		
		cell?.onPlay = { [weak self] track in
			self?.presenter.play(trackUID: track)
		}
		
		cell?.onLike = { [weak self] track in
			self?.presenter.like(trackUID: track)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 24
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return nil
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.cellHeight
        return FeedCell.recommendedHeight()
    }
    
}

