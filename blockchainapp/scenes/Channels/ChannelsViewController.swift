//
//  ChannelsViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SDWebImage
import TagListView

class ChannelsCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var listensLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    
	@IBOutlet weak var noTagsView: UILabel!
	@IBOutlet weak var tagsView: TagListView!
	@IBOutlet weak var subscribeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 9
        
        subscribeButton.layer.cornerRadius = 6
        subscribeButton.layer.borderWidth  = 1
        subscribeButton.layer.borderColor  = UIColor.vaRed.cgColor
        subscribeButton.titleLabel?.font = UIFont(name: ".SFUIText-Medium", size: 16)
        subscribeButton.titleLabel?.minimumScaleFactor = 0.1
        subscribeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        nameLabel.font = UIFont(name: ".SFUIText-Medium", size: 18)!
        subscribersLabel.font = UIFont(name: ".SFUIText-Medium", size: 12)!
        listensLabel.font = UIFont(name: ".SFUIText-Medium", size: 12)!
        
        nameLabel.textColor = UIColor.vaCharcoalGrey
		
		tagsView.textFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
		tagsView.tagLineBreakMode = .byTruncatingTail
		
		for _ in 0..<4 {
			self.tagsView.addTag(" ")
		}
    }
    
    class func recommendedHeight() -> CGFloat {
        return 164/* image */ + 13/* pad */ + 13/* pad */
    }
    
    weak var channel: Station? = nil {
        didSet {
            nameLabel.text = channel?.name
            subscribersLabel.text = "\(channel?.subscriptionCount ?? 0)"
			self.tagsView.removeAllTags()
			if let tags = channel?.tags.map({$0.value}).prefix(4) {
				if tags.count != 0 {
					self.tagsView.addTags(tags.map({$0.uppercased()}))
					self.noTagsView.isHidden = true
					tagsView.isHidden = false
				} else {
					self.noTagsView.isHidden = false
					self.tagsView.isHidden = true
				}
			} else {
				self.noTagsView.isHidden = false
				self.tagsView.isHidden = true
			}
            if let urlString = channel?.image.buildImageURL() {
                iconImageView.sd_setImage(with: urlString)
            } else {
                iconImageView.image = nil
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        subscribeButton.isSelected = selected
        heartImageView.image = selected ? #imageLiteral(resourceName: "heartActive") : #imageLiteral(resourceName: "heartInactive")
        subscribeButton.backgroundColor = selected ? UIColor.clear : UIColor.vaActive
    }
    
}

class ChannelsViewController: UITableViewController, ChannelsViewProtocol {
    
    var presenter: ChannelsPresenter!
    var source = [Station]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
        navigationController?.navigationBar.prefersLargeTitles = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        presenter = ChannelsPresenter(view: self)
        
        view.backgroundColor = UIColor.vaWhite

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.allowsMultipleSelection = true
        tableView.refreshControl = refreshControl
		
		tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.cellID)
		
		
        presenter.getData { [weak self] (channels) in
            self?.display(channels: channels)
        }
//		refreshControl?.beginRefreshing()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.tableView.reloadData()
	}
    
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
        presenter.getData { [weak self] (channels) in
            self?.display(channels: channels)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func display(channels: [Station]) {
        source = channels
        tableView.reloadData()
        
        refreshControl?.endRefreshing()
    }
    
    func select(rows: [Int]) {
        for r in rows {
            tableView.selectRow(at: IndexPath(row: r, section: 0),
                                animated: false,
                                scrollPosition: .none)
        }
    }

}

extension ChannelsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.cellID, for: indexPath) as! ChannelTableViewCell
		let station = source[indexPath.row]
        cell.channel = station
		cell.subAction = {[weak self] channel in
			if let ch = channel {
				self?.presenter.select(station: ch)
			}
		}
		cell.subButton.isSelected = presenter.subManager.hasStation(id: station.id)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelTableViewCell.height//ChannelsCell.recommendedHeight()
    }
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return ChannelTableViewCell.height//ChannelsCell.recommendedHeight()
	}
}

extension ChannelsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let station = self.source[indexPath.row]
		let vc = ChannelViewController(station: station)
		self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
    
}
