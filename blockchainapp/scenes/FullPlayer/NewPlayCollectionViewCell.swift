//
//  NewPlayCollectionViewCell.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 22/11/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyAudioManager

class NewPlayCollectionViewCell: UICollectionViewCell {
	
	static let cellID: String = "PlayerCellID"
	
	let trackImage: UIImageView = {
		let imageView = UIImageView()
		imageView.snp.makeConstraints({ (make) in
			make.width.equalTo(40)
			make.height.equalTo(40)
		})
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 6
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let channelLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = UIColor.init(white: 74.0/255, alpha: 1)
		return label
	}()
	
	let trackLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		label.textColor = UIColor.init(white: 74.0/255, alpha: 1)
		return label
	}()
	
	let progressView: UIProgressView = {
		let progress = UIProgressView(progressViewStyle: .bar)
		let tomato = UIColor.init(red: 243.0/255, green: 71.0/255, blue: 36.0/255, alpha: 1)
		progress.trackTintColor = tomato.withAlphaComponent(0.1)
		progress.progressTintColor = tomato.withAlphaComponent(0.2)
		progress.setProgress(0.5, animated: true)
		return progress
	}()
	
	let playButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage.init(named: "playInacteive"), for: .normal)
		button.setImage(UIImage.init(named: "pauseInacteive"), for: .selected)
		button.snp.makeConstraints({ (make) in
			make.width.equalTo(36)
			make.height.equalTo(36)
		})
		return button
	}()
	
	let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
	
	public weak var track: Track? = nil {
		didSet {
			trackLabel.text = track?.name
			channelLabel.text = track?.findStationName()
			
			if let iconUrl = track?.image.buildImageURL() {
				trackImage.sd_setImage(with: iconUrl)
			} else {
				trackImage.image = nil
			}
		}
	}
	
	let audioManager = AppManager.shared.audioManager
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		viewinitialize()

		self.playButton.addTarget(self , action: #selector(playButtonPressed(_:)), for: .touchUpInside)
		
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
	
	private func startAnimateVaiting() {
		DispatchQueue.main.async {
			self.activityIndicator.startAnimating()
			self.playButton.isHidden = true
		}
	}
	
	// MARK: - Buttons pressing
	
	@objc func playButtonPressed(_ sender: Any) {
		if audioManager.isPlaying {
			audioManager.pause()
		} else {
			audioManager.resume()
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private func updatePlayButtonState() {
		DispatchQueue.main.async {
			self.activityIndicator.stopAnimating()
			self.playButton.isHidden = false
			self.playButton.isSelected = self.audioManager.isPlaying
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
				self.progressView.setProgress(Float(currentTime / maxTime), animated: true)
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
				self.progressView.setProgress(0, animated: true)
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
	
	
	func viewinitialize() {
		self.contentView.addSubview(trackImage)
		trackImage.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalToSuperview().inset(12)
		}
		
		self.contentView.addSubview(channelLabel)
		channelLabel.snp.makeConstraints { (make) in
			make.top.equalTo(trackImage)
			make.left.equalTo(trackImage.snp.right).inset(-16)
			make.right.equalToSuperview().inset(72)
		}
		
		self.contentView.addSubview(trackLabel)
		trackLabel.snp.makeConstraints { (make) in
			make.left.equalTo(channelLabel)
			make.bottom.equalTo(trackImage)
			make.right.equalTo(channelLabel)
		}
		
		self.contentView.addSubview(progressView)
		progressView.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().inset(6)
		}
		
		self.contentView.addSubview(playButton)
		playButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(14)
			make.right.equalToSuperview().inset(18)
		}
		
		self.contentView.addSubview(activityIndicator)
		activityIndicator.snp.makeConstraints { (make) in
			make.center.equalTo(playButton)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
