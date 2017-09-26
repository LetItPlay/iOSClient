//
//  PlayerViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 04/09/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SwiftyAudioManager

class PlayerViewController: UIViewController {
    
    let audioManager = AppManager.shared.audioManager
    
    private var movePercent = 0.05
    
    @IBOutlet weak var btnRemoteBack: UIButton!
    @IBOutlet weak var btnPrevTrack: UIButton!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var btnNextTrack: UIButton!
    @IBOutlet weak var btnRemoteNext: UIButton!
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var backProgressView: UIView!
    @IBOutlet weak var faceProgressView: UIView!
    
    @IBOutlet weak var progressViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func audioManagerStartPlaying(_ notification: Notification) {
        guard (notification.object as? AudioManager) === audioManager else {
            return
        }
        
        showPlayer()
    }
    
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
            movePercent = 15 / maxTime
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.01, animations: {
                    self.progressViewWidthConstraint.constant = self.backProgressView.frame.width * CGFloat(currentTime / maxTime)
                    
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
                
                self.leftLabel.text  = "00:00"
                self.rightLabel.text = "-00:00"
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
    
    @IBAction func remoteLeftButtonPressed(_ sender: Any) {
        audioManager.itemProgressPercent -= movePercent
    }
    
    @IBAction func remoteRightButtonPressed(_ sender: Any) {
        audioManager.itemProgressPercent += movePercent
    }
    
    @IBAction func prevTrackButtonPressed(_ sender: Any) {
        audioManager.playPrevious()
    }
    
    @IBAction func nextTrackButtonPressed(_ sender: Any) {
        audioManager.playNext()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
