//
//  FeedViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var listeningLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    public var onPlay: ((Track) -> Void)?
    public var onLike: ((Track) -> Void)?
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
        commentLabel.font   = UIFont(name: ".SFUIText-Medium", size: 12)
        
        likesLabel.textColor     = UIColor.vaCharcoalGrey
        listeningLabel.textColor = UIColor.vaCharcoalGrey
        commentLabel.textColor   = UIColor.vaCharcoalGrey
        
    }
    
    class func recommendedHeight() -> CGFloat {
        return 192
    }
    
    var track: Track? = nil {
        didSet {
            nameLabel.text = track?.name
            
            if let iconUrl = track?.image.buildImageURL() {
                iconImageView.sd_setImage(with: iconUrl)
            } else {
                iconImageView.image = nil
            }
            
            likesLabel.text = "\(track?.linkCount ?? 0) likes"
            listeningLabel.text = "0 listening"
            commentLabel.text = "0 comments"
        }
    }
    
    // MARK: - buttons
    @IBAction func commentPressed(_ sender: Any) {
        if track != nil {
            onComment?(track!)
        }
    }
    
    @IBAction func playPressed(_ sender: Any) {
        if track != nil {
            onPlay?(track!)
        }
    }
    
    @IBAction func likePressed(_ sender: Any) {
        if track != nil {
            onLike?(track!)
        }
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if track != nil {
            onMenu?(track!)
        }
    }
}

class FeedViewController: UIViewController, FeedViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: FeedPresenterProtocol!
    fileprivate var source = [Track]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FeedPresenter(view: self)
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.vaWhite

        tableView.dataSource = self
        tableView.delegate   = self
        
        presenter.getData { [weak self] (tracks) in
            self?.display(tracks: tracks)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func display(tracks: [Track]) {
        source = tracks
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

extension FeedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FeedCell
        cell.track = source[indexPath.row]
        
        cell.onPlay = { [weak self] track in
            self?.presenter.play(track: track)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FeedCell.recommendedHeight()
    }
    
}

extension FeedViewController: UITableViewDelegate {
    
}
