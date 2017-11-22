//
//  FullPlayerViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 19/10/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import MediaPlayer
import SwiftyAudioManager
import ShadowView

class FullPlayerViewController: UIViewController {
    
    var presenter: FullPlayerPresenterProtocol!
    let audioManager = AppManager.shared.audioManager

    @IBOutlet weak var progressSliderView: UISlider!
    @IBOutlet weak var volumeBackView: UIView!
    
    @IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var bluredPhotoImageView: UIImageView!
	
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var shadowView: ShadowView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftLabel.font  = UIFont(name: ".SFUIText-Semibold", size: 12)
        rightLabel.font = UIFont(name: ".SFUIText-Semibold", size: 12)
        
        nameLabel.font = UIFont(name: ".SFUIText-Bold", size: 18)
        stationLabel.font = UIFont(name: ".SFUIText-Medium", size: 18)

        progressSliderView.setThumbImage(UIImage.circle(diameter: 14, color: UIColor.vaRed), for: UIControlState.normal)
        
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 7
        
        let myVolumeView = MPVolumeView(frame: volumeBackView.bounds)
        myVolumeView.showsRouteButton = false
        volumeBackView.addSubview(myVolumeView)
        myVolumeView.translatesAutoresizingMaskIntoConstraints = false
        myVolumeView.tintColor = UIColor.vaRed
        myVolumeView.setVolumeThumbImage(UIImage.circle(diameter: 14, color: UIColor.white), for: UIControlState.normal)
        myVolumeView.topAnchor.constraint(equalTo: volumeBackView.topAnchor).isActive = true
        myVolumeView.bottomAnchor.constraint(equalTo: volumeBackView.bottomAnchor).isActive = true
        myVolumeView.leftAnchor.constraint(equalTo: volumeBackView.leftAnchor).isActive = true
        myVolumeView.rightAnchor.constraint(equalTo: volumeBackView.rightAnchor).isActive = true
        
        presenter = FullPlayerPresenter(view: self)
        
        //subscribe
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerPaused(_:)),
                                               name: AudioManagerNotificationName.paused.notification,
                                               object: audioManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioManagerStartPlaying(_:)),
                                               name: AudioManagerNotificationName.startPlaying.notification,
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shadowView.updateShadow()
        startRunnigRow()
    }
    
    func startRunnigRow() {
        nameLabel.setNeedsLayout()
        nameLabel.layoutIfNeeded()
        nameLabel.layer.removeAllAnimations()
        nameLabel.transform = .identity
        if nameLabel.frame.width > nameLabel.superview!.frame.width {
            let diff = nameLabel.superview!.frame.width - nameLabel.frame.width
            nameLabel.transform = CGAffineTransform(translationX: -diff, y: 0)
            UIView.animate(withDuration: 5,
                           delay: 3,
                           options: [.autoreverse, .repeat], animations: { [weak self] in
                            self?.nameLabel.transform = CGAffineTransform(translationX: diff, y: 0)
                }, completion: { (finished) in
                    
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Player buttons
    
    @IBAction func previousTrackPressed(_ sender: Any) {
        audioManager.playPrevious()
    }
    
    @IBAction func nextTrackPressed(_ sender: Any) {
        audioManager.playNext()
    }
    
    @IBAction func playTrackPressed(_ sender: Any) {
        if audioManager.isPlaying {
            audioManager.pause()
        } else {
            audioManager.resume()
        }
    }
    
    @IBAction func progressValueChanged(_ sender: UISlider) {
        audioManager.itemProgressPercent = Double(sender.value)
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        likeButton.isSelected = !likeButton.isSelected
        presenter.like()
    }
    
    
}

extension FullPlayerViewController {
    private func updatePlayButtonState() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.playButton.isHidden = false
            self.playButton.isSelected = self.audioManager.isPlaying
        }
    }
    
    // MARK: - AudioManager events
    @objc func audioManagerStartPlaying(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
    }
    
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
        if !progressSliderView.isTouchInside {
            if let currentTime = notification.userInfo?["currentTime"] as? Double,
                let maxTime = notification.userInfo?["maxTime"] as? Double {
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.01, animations: {
                        self.progressSliderView.value = Float(currentTime / maxTime)
                        
                        var minutes = Int(currentTime) / 60 % 60
                        var seconds = Int(currentTime) % 60
                        
                        self.leftLabel.text = String(format:"%02i:%02i", minutes, seconds)
                        
                        minutes = Int(maxTime - currentTime) / 60 % 60
                        seconds = Int(maxTime - currentTime) % 60
                        
                        self.rightLabel.text = String(format:"-%02i:%02i", minutes, seconds)
                    })
                }
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
            self.presenter.fetch()
            UIView.animate(withDuration: 0.01, animations: {
                self.progressSliderView.value = 0
                
                self.leftLabel.text  = "00:00"
                self.rightLabel.text = "-00:00"
            })
        }
    }
    
    @objc func audioManagerNextPlayed(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        startAnimateVaiting()
    }
    
    @objc func audioManagerPreviousPlayed(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        startAnimateVaiting()
    }
    
    @objc func audioManagerRecievedPlay(_ notification: Notification) {
//        guard (notification.object as? AudioManager) === audioManager else {
//            return
//        }
        startAnimateVaiting()
    }
    
    private func startAnimateVaiting() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.playButton.isHidden = true
        }
    }
}

extension FullPlayerViewController: FullPlayerViewProtocol {
    func display(name: String, station: String, image: URL?, isLiked: Bool) {
        nameLabel.text = name
        stationLabel.text = station
        likeButton.isSelected = isLiked
        photoImageView.sd_setImage(with: image) { [weak self] (image, error, cacheType, url) in
            self?.shadowView.updateShadow()
        }
        
        startRunnigRow()
    }
}
