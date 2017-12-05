//
//  PlayerController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 28/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import LNPopupController
import SnapKit
import SwiftyAudioManager
import RealmSwift
import SDWebImage

class PopupController: LNPopupCustomBarViewController {
	
	var playerView: PlayerView!
	
	var actIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
	var playButton: UIButton = {
		let play = UIButton()
		play.setImage(UIImage(named: "playInactive"), for: .normal)
		play.setImage(UIImage(named: "stopInactive"), for: .selected)
		play.setBackgroundImage(AppColor.Element.tomato.withAlphaComponent(0.1).img(), for: .highlighted)
		play.layer.cornerRadius = 20
		play.layer.masksToBounds = true
		play.snp.makeConstraints { (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		}
		return play
	}()
	
	var nextButton: UIButton = {
		let next = UIButton()
		next.setImage(UIImage.init(named: "popupNextInactive"), for: .normal)
		next.setBackgroundImage(AppColor.Element.tomato.withAlphaComponent(0.1).img(), for: .highlighted)
		next.layer.cornerRadius = 20
		next.layer.masksToBounds = true
		next.snp.makeConstraints { (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		}
		return next
	}()
	
	let audioManager = AppManager.shared.audioManager
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.popupBar.marqueeScrollEnabled = true
		self.popupBar.progressViewStyle = .bottom
		
		self.popupBar.titleTextAttributes = [NSAttributedStringKey.font.rawValue: AppFont.Text.mid, NSAttributedStringKey.foregroundColor.rawValue: AppColor.Title.gray]
		self.popupBar.subtitleTextAttributes = [NSAttributedStringKey.font.rawValue: AppFont.Title.sml, NSAttributedStringKey.foregroundColor.rawValue: AppColor.Title.gray]
		
		self.popupBar.layoutSubviews()
		
		let playContainer: UIView = UIView()
		playContainer.addSubview(playButton)
		playButton.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		playContainer.addSubview(actIndicator)
		actIndicator.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
		}
		
		self.popupItem.rightBarButtonItems = [playContainer, nextButton].map({UIBarButtonItem.init(customView: $0)})
		
		self.popupItem.title = ""
		self.popupItem.subtitle = ""
		
		self.popupItem.progress = 0.0
		self.popupBar.progressViewStyle = .bottom
		
		self.popupBar.isHidden = true
		
		self.playerView = PlayerView.init(frame: self.view.frame)
		self.view.addSubview(playerView)
		
		playerView.snp.makeConstraints({ (make) in
			make.edges.equalToSuperview()
		})
		
		self.playerView.volumeSlider.value = self.audioManager.currentVolume
		
		self.playButton.addTarget(self, action: #selector(playPressed(sender:)), for: .touchUpInside)
		self.playerView.playButton.addTarget(self, action: #selector(playPressed(sender:)), for: .touchUpInside)
		
		self.nextButton.addTarget(self, action: #selector(nextTrackButtonPressed(_:)), for: .touchUpInside)
		self.playerView.trackChangeButtons.next.addTarget(self, action: #selector(nextTrackButtonPressed(_:)), for: .touchUpInside)
		
		self.playerView.trackChangeButtons.prev.addTarget(self, action: #selector(prevTrackButtonPressed(_:)), for: .touchUpInside)
		
		self.playerView.trackSeekButtons.forw.addTarget(self, action: #selector(remoteRightButtonPressed(_:)), for: .touchUpInside)
		self.playerView.trackSeekButtons.backw.addTarget(self, action: #selector(remoteLeftButtonPressed(_:)), for: .touchUpInside)
		
		self.playerView.trackProgressView.addTarget(self, action: #selector(trackSeekChanged(_:)), for: .touchUpInside)
		
		self.subscribe()
	}
	
	func updateTrackInfo() {
		if let trackStat =  self.audioManager.currentItemId,
			let stringId = trackStat.split(separator: "_").first,
			let id = Int(stringId) {
			
			let trackId = id
			
			let realm = try! Realm()
			if let ob = realm.object(ofType: Track.self, forPrimaryKey: id) {
				let channel = ob.findStationName() ?? ""
				let title = ob.name
				let url = ob.findChannelImage()
				
				self.popupItem.title = channel
				self.popupItem.subtitle = title
				self.playerView.channelNameLabel.text = channel
				self.playerView.trackNameLabel.text = title
				self.playerView.coverImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: { (img, error, type, url) in
					self.popupItem.image = img
					self.playerView.underblurimageView.image = img
				})
			}
		}
	}
	
	@objc func trackSeekChanged(_ sender: Any) {
		audioManager.itemProgressPercent = Double(self.playerView.trackProgressView.slider.value)
	}
	
	@objc func playPressed(sender: UIButton) {
		if audioManager.isPlaying {
			audioManager.pause()
		} else {
			audioManager.resume()
		}
	}
	
	@objc func remoteLeftButtonPressed(_ sender: Any) {
		let progress = audioManager.itemProgressPercent - 10.0/audioManager.maxTime
		audioManager.itemProgressPercent = progress <= 0 ? 0 : progress
	}
	
	@objc func remoteRightButtonPressed(_ sender: Any) {
		let progress = audioManager.itemProgressPercent + 10.0/audioManager.maxTime
		audioManager.itemProgressPercent = progress >= 1.0 ? 0 : progress
	}
	
	@objc func prevTrackButtonPressed(_ sender: Any) {
		audioManager.playPrevious()
	}
	
	@objc func nextTrackButtonPressed(_ sender: Any) {
		audioManager.playNext()
	}
	
	// MARK: - Private
	private func updatePlayButtonState() {
		DispatchQueue.main.async {
			self.actIndicator.stopAnimating()
			self.playButton.isHidden = false
			self.playButton.isSelected = self.audioManager.isPlaying
			self.playerView.playButton.isSelected = self.audioManager.isPlaying
		}
	}
	
	// MARK: - AudioManager events
	@objc func audioManagerStartPlaying(_ notification: Notification) {
		updatePlayButtonState()
	}
	
	@objc func audioManagerPaused(_ notification: Notification) {
		if audioManager.isOnPause {
			updatePlayButtonState()
		}
	}
	
	@objc func audioManagerEndPlaying(_ notification: Notification) {
		updatePlayButtonState()
	}
	
	@objc func audioManagerPlaySoundOnSecond(_ notification: Notification) {
		/*
		let info: [String : Any] = ["itemID" : currentItemId ?? "",
		"currentTime" : currentTime,
		"maxTime": maxTime]
		*/
		if let currentTime = notification.userInfo?["currentTime"] as? Double,
			let maxTime = notification.userInfo?["maxTime"] as? Double {
			DispatchQueue.main.async {
				UIView.animate(withDuration: 0.01, animations: {
					self.popupItem.progress = Float(currentTime / maxTime)
					if !self.playerView.trackProgressView.slider.isHighlighted {
						self.playerView.trackProgressView.slider.value = Float(currentTime / maxTime)
					}
					
					var minutes = Int(currentTime) / 60 % 60
					var seconds = Int(currentTime) % 60
					
					self.playerView.trackProgressView.trackProgressLabels.start.text = String(format:"%02i:%02i", minutes, seconds)
					
					minutes = Int(maxTime - currentTime) / 60 % 60
					seconds = Int(maxTime - currentTime) % 60
					
					self.playerView.trackProgressView.trackProgressLabels.fin.text = String(format:"-%02i:%02i", minutes, seconds)
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
		self.popupBar.isHidden = false
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.01, animations: {
				self.playerView.trackProgressView.slider.value = 0
				self.playerView.trackProgressView.trackProgressLabels.start.text  = "00:00"
				self.playerView.trackProgressView.trackProgressLabels.fin.text = "-00:00"
				
				self.popupItem.progress = 0
				
				self.updateTrackInfo()
			})
		}
	}
	
	@objc func audioManagerNextPlayed(_ notification: Notification) {
		startAnimateVaiting()
	}
	
	@objc func audioManagerPreviousPlayed(_ notification: Notification) {
		startAnimateVaiting()
	}
	
	@objc func audioManagerRecievedPlay(_ notification: Notification) {
		startAnimateVaiting()
	}
	
	@objc func volumeChanged(_ notification: Notification) {
		guard let volume = notification.userInfo?["volume"] as? Float else {
			self.playerView.volumeSlider.value = 0
			return
		}
		self.playerView.volumeSlider.value = volume
	}
	
	private func startAnimateVaiting() {
		DispatchQueue.main.async {
			self.actIndicator.startAnimating()
			self.playButton.isHidden = true
		}
	}
	
	func subscribe() {
		
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
		NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(_:)), name: AudioManagerNotificationName.volumeChanged.notification, object: audioManager)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
