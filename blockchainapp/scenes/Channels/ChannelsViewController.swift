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
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var subscribeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 20
        
        nameLabel.font = UIFont(name: ".SFUIText-Bold", size: 12)!
        infoLabel.font = UIFont(name: ".SFUIText-Medium", size: 12)!
        
        nameLabel.textColor = UIColor.vaCharcoalGrey
        infoLabel.textColor = UIColor.vaCharcoalGrey
        infoLabel.alpha = 0.8
    }
    
    class func recommendedHeight() -> CGFloat {
        return 80
    }
    
    var channel: Station? = nil {
        didSet {
            nameLabel.text = channel?.name
            infoLabel.text = "\(channel?.subscriptionCount ?? 0) subscribers"
            
            if let urlString = channel?.image.buildImageURL() {
                iconImageView.sd_setImage(with: urlString)
            } else {
                iconImageView.image = nil
            }
        }
    }
    
}

class ChannelsViewController: UIViewController, ChannelsViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: ChannelsPresenter!
    var source = [Station]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ChannelsPresenter(view: self)
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.vaWhite

        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChannelsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChannelsCell
        cell.channel = source[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChannelsCell.recommendedHeight()
    }
}

extension ChannelsViewController: UITableViewDelegate {
    
    
}
