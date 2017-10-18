//
//  AudioCoreViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 13/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SwiftyAudioManager
import RealmSwift

protocol AudioCore {
    func play()
    func pause()
}

class AudioCoreViewController: UIViewController {
    let audioManager = AppManager.shared.audioManager
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var feedToken: NotificationToken? = nil
    var tracks: Results<Track>? = nil
    var currentTrackIndex: Int = -1
    
    deinit {
        feedToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate   = self
        
        let realm = try! Realm()
        tracks = realm.objects(Track.self)
        feedToken = tracks?.addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.collectionView.reloadData()
                
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                self?.collectionView.reloadData()
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
            
        })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerStartPlaying(_:)),
                                               name: AudioManagerNotificationName.startPlaying.notification,
                                               object: audioManager)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Public UI manipulation
    
    public func showPlayer() {
        UIView.animate(withDuration: 0.4) {
            self.view.transform = .identity
            self.view.alpha = 1
        }
    }
    
    public func hidePlayer() {
        UIView.animate(withDuration: 0.4) {
            self.view.transform = CGAffineTransform(translationX: 0, y: 49)
            self.view.alpha = 0
        }
    }
    
    //MARK: - Notifications
    
    func audioManagerStartPlaying(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        
        if audioManager.currentIndex != currentTrackIndex {
            DispatchQueue.main.async {
                let ip = IndexPath(item: self.audioManager.currentIndex, section: 0)
                self.collectionView.scrollToItem(at: ip,
                                                 at: UICollectionViewScrollPosition.right,
                                                 animated: true)
            }
        }
        
        showPlayer()
    }
}

extension AudioCoreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension AudioCoreViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let cell = collectionView.visibleCells.first,
            let indexPath = collectionView.indexPath(for: cell) else {
                return
        }
        if indexPath.item != currentTrackIndex {
            currentTrackIndex = indexPath.item
            guard let track = tracks?[indexPath.item] else { return }
            
            audioManager.playItem(with: track.uniqString())
        }
    }
}

extension AudioCoreViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AudioCoreCell
        cell.track = tracks?[indexPath.row]
        return cell
    }
}

//MARK: - Cell

protocol AudioCoreCellDelegate {
    
}

class AudioCoreCell: UICollectionViewCell {
    
    let audioManager = AppManager.shared.audioManager
    
    public weak var track: Track? = nil {
        didSet {
            nameLabel.text = track?.name
            stationNameLabel.text = track?.findStationName()
            
            if let iconUrl = track?.image.buildImageURL() {
                imageView.sd_setImage(with: iconUrl)
            } else {
                imageView.image = nil
            }
        }
    }
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var backProgressView: UIView!
    @IBOutlet weak var faceProgressView: UIView!
    
    @IBOutlet weak var progressViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.font = UIFont(name: ".SFUIText-Bold", size: 14)
        stationNameLabel.font = UIFont(name: ".SFUIText-Regular", size: 14)
        
        nameLabel.textColor = UIColor.vaCharcoalGrey
        stationNameLabel.textColor = UIColor.vaCharcoalGrey
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerPaused(_:)),
                                               name: AudioManagerNotificationName.paused.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerEndPlaying(_:)),
                                               name: AudioManagerNotificationName.endPlaying.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerPlaySoundOnSecond(_:)),
                                               name: AudioManagerNotificationName.playSoundOnSecond.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerFailed(_:)),
                                               name: AudioManagerNotificationName.failed.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerResume(_:)),
                                               name: AudioManagerNotificationName.resumed.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerReadyToPlay(_:)),
                                               name: AudioManagerNotificationName.readyToPlay.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerRecievedPlay(_:)),
                                               name: AudioManagerNotificationName.receivedPlayCommand.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerPreviousPlayed(_:)),
                                               name: AudioManagerNotificationName.previousPlayed.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerNextPlayed(_:)),
                                               name: AudioManagerNotificationName.nextPlayed.notification,
                                               object: audioManager)
    }
    
    // MARK: - Private
    private func updatePlayButtonState() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.btnPlay.isHidden = false
            self.btnPlay.isSelected = self.audioManager.isPlaying
        }
    }
    
    // MARK: - AudioManager events
    
    func audioManagerPaused(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        
        if audioManager.isOnPause {
            updatePlayButtonState()
        }
    }
    
    func audioManagerEndPlaying(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        
        updatePlayButtonState()
    }
    
    func audioManagerPlaySoundOnSecond(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        
        updatePlayButtonState()
        /*
         let info: [String : Any] = ["itemID" : currentItemId ?? "",
         "currentTime" : currentTime,
         "maxTime": maxTime]
         */
        if let currentTime = notification.userInfo?["currentTime"] as? Double,
            let maxTime = notification.userInfo?["maxTime"] as? Double {
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.01, animations: {
                    self.progressViewWidthConstraint.constant = self.backProgressView.frame.width * CGFloat(currentTime / maxTime)
                })
            }
        }
    }
    
    func audioManagerFailed(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        updatePlayButtonState()
    }
    
    func audioManagerResume(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        updatePlayButtonState()
    }
    
    func audioManagerReadyToPlay(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.01, animations: {
                self.progressViewWidthConstraint.constant = 0
            })
        }
    }
    
    func audioManagerNextPlayed(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        startAnimateVaiting()
//        delegateChangingItem()
    }
    
    func audioManagerPreviousPlayed(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        startAnimateVaiting()
//        delegateChangingItem()
    }
    
    func audioManagerRecievedPlay(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        startAnimateVaiting()
//        delegateChangingItem()
    }
    
    private func startAnimateVaiting() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.btnPlay.isHidden = true
        }
    }
    
    // MARK: - Buttons pressing
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if audioManager.isPlaying {
            audioManager.pause()
        } else {
            audioManager.resume()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
