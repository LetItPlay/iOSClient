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

protocol AudioCore: AudioManagerProtocol {
    
}

class AudioCoreViewController: UIViewController {
    let audioManager = AppManager.shared.audioManager
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var feedToken: NotificationToken? = nil
    var tracks: Results<Track>? = nil
    var currentTrackIndex: Int = -1
    
    private var playList = [PlayerItem]()
    private var startTime: Double = 0
    
    deinit {
        feedToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate   = self
        
        let realm = try! Realm()
        tracks = realm.objects(Track.self).sorted(byKeyPath: "publishedAt", ascending: false)
        feedToken = tracks?.observe({ [weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.collectionView.reloadData()
                self?.updatePlayList(feed: Array(self!.tracks!),
                                     deletions: [],
                                     insertions: [],
                                     modifications: [])
                
            case .update(_, let deletions, let insertions, let modifications):
                self?.collectionView.reloadData()
                self?.updatePlayList(feed: Array(self!.tracks!),
                                     deletions: deletions,
                                     insertions: insertions,
                                     modifications: modifications)
                
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
    
    private func updatePlayList(feed: [Track], deletions: [Int], insertions: [Int], modifications: [Int]) {
        if deletions.isEmpty && insertions.isEmpty && modifications.isEmpty ||
            !deletions.isEmpty ||
            !insertions.isEmpty {
            playList = [PlayerItem]()
            
            for f in feed {
                let playerItem = PlayerItem(itemId: f.uniqString(),
                                            url: f.audiofile?.file.buildImageURL()?.absoluteString ?? "")
                playerItem.autoLoadNext = true
                playerItem.autoPlay = true
                
                playList.append(playerItem)
            }
            
            startTime = 0
            
            if !playList.isEmpty {
                
                var currentId: String? = nil
                
                if audioManager.isPlaying {
                    currentId = audioManager.currentItemId
                    startTime = audioManager.itemProgressPercent
                }
                
                audioManager.resetPlaylistAndStop()
                let group = PlayerItemsGroup(id: "120", name: "main", playerItems: playList)
                audioManager.add(playlist: [group])
                
                if currentId != nil {
                    audioManager.playItem(with: currentId!)
                }
            }
        }
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
    
    @objc func audioManagerStartPlaying(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        
        if startTime != 0 {
            audioManager.itemProgressPercent = startTime
            startTime = 0
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

extension AudioCoreViewController: AudioCore {
    var resetOnLast: Bool {
        get {
            return audioManager.resetOnLast
        }
        set(newValue) {
            audioManager.resetOnLast = resetOnLast
        }
    }
    
    var currentGroupIndex: Int {
        get {
            return audioManager.currentGroupIndex
        }
        set(newValue) {
            audioManager.currentGroupIndex = currentGroupIndex
        }
    }
    
    var playlist: [PlayerItemsGroup]? {
        return audioManager.playlist
    }
    
    var playlistGroupCount: Int {
        return audioManager.playlistGroupCount
    }
    
    func itemsCount(in group: Int) -> Int {
        return audioManager.itemsCount(in: group)
    }
    
    var currentIndex: Int {
        return audioManager.currentIndex
    }
    
    var currentItem: PlayerItem? {
        return audioManager.currentItem
    }
    
    var currentItemId: String? {
        return audioManager.currentItemId
    }
    
    var isPlaying: Bool {
        return audioManager.isPlaying
    }
    
    var isOnPause: Bool {
        return audioManager.isOnPause
    }
    
    var itemProgressPercent: Double {
        get {
            return audioManager.itemProgressPercent
        }
        set(newValue) {
            audioManager.itemProgressPercent = newValue
        }
    }
    
    var isPlayingSpeakerMode: Bool {
        get {
            return audioManager.isPlayingSpeakerMode
        }
        set(newValue) {
            audioManager.isPlayingSpeakerMode = newValue
        }
    }
    
    func add(playlist: [PlayerItemsGroup]) {
        audioManager.add(playlist: playlist)
    }
    
    func play(playlist: [PlayerItemsGroup]) {
        audioManager.play(playlist: playlist)
    }
    
    func pause() {
        audioManager.pause()
    }
    
    func resume() {
        audioManager.pause()
    }
    
    func stop() {
        audioManager.stop()
    }
    
    func playNext() {
        audioManager.playNext()
    }
    
    func playPrevious() {
        audioManager.playPrevious()
    }
    
    func resetPlaylistAndStop() {
        audioManager.resetPlaylistAndStop()
    }
    
    public func playItem(at index: Int) {
        audioManager.playItem(at: index)
    }
    
    public func playItem(with id: String) {
        audioManager.playItem(with: id)
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
    
    @objc func audioManagerPaused(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        
        if audioManager.isOnPause {
            updatePlayButtonState()
        }
    }
    
    @objc func audioManagerEndPlaying(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        
        updatePlayButtonState()
    }
    
    @objc func audioManagerPlaySoundOnSecond(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        
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
    
    @objc func audioManagerFailed(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        updatePlayButtonState()
    }
    
    @objc func audioManagerResume(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        updatePlayButtonState()
    }
    
    @objc func audioManagerReadyToPlay(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.01, animations: {
                self.progressViewWidthConstraint.constant = 0
            })
        }
    }
    
    @objc func audioManagerNextPlayed(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        startAnimateVaiting()
//        delegateChangingItem()
    }
    
    @objc func audioManagerPreviousPlayed(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        startAnimateVaiting()
//        delegateChangingItem()
    }
    
    @objc func audioManagerRecievedPlay(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
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
