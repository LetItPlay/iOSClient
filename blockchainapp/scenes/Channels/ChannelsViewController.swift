//
//  ChannelsViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 31/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SDWebImage

class ChannelsCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var listensLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    
    @IBOutlet weak var subscribeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 9
        
        subscribeButton.layer.cornerRadius = 6
        subscribeButton.layer.borderWidth  = 1
        subscribeButton.layer.borderColor  = UIColor.vaRed.cgColor
        subscribeButton.titleLabel?.font = UIFont(name: ".SFUIText-Medium", size: 16)
        
        nameLabel.font = UIFont(name: ".SFUIText-Medium", size: 18)!
        subscribersLabel.font = UIFont(name: ".SFUIText-Medium", size: 12)!
        listensLabel.font = UIFont(name: ".SFUIText-Medium", size: 12)!
        
        nameLabel.textColor = UIColor.vaCharcoalGrey
    }
    
    class func recommendedHeight() -> CGFloat {
        return 164/* image */ + 13/* pad */ + 13/* pad */
    }
    
    weak var channel: Station? = nil {
        didSet {
            nameLabel.text = channel?.name
            subscribersLabel.text = "\(channel?.subscriptionCount ?? 0)"
            
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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        presenter = ChannelsPresenter(view: self)
        
        view.backgroundColor = UIColor.vaWhite

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.allowsMultipleSelection = true
        tableView.refreshControl = refreshControl
        
        
        presenter.getData { [weak self] (channels) in
            self?.display(channels: channels)
        }
    }
    
    func onRefreshAction(refreshControl: UIRefreshControl) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChannelsCell
        cell.channel = source[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelsCell.recommendedHeight()
    }
}

extension ChannelsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = source[indexPath.row]
        presenter.select(station: channel)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let channel = source[indexPath.row]
        presenter.select(station: channel)
    }
    
}
