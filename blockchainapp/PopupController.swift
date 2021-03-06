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

import RealmSwift
import SDWebImage
import MediaPlayer

class CustomScrollView: UIScrollView {	
	override func touchesShouldCancel(in view: UIView) -> Bool {
		let needTouch = view is TimedSlider || view is MPVolumeView
		return !needTouch
	}
}

class PopupController: LNPopupCustomBarViewController, AudioControllerDelegate {
	var playerView: PlayerView!
	var playlistView: PlaylistView!
	
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
	
	let audioController = AudioController.main
	
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
		self.playlistView = PlaylistView.init()
		
		self.playButton.addTarget(self, action: #selector(playPressed(sender:)), for: .touchUpInside)
		self.playerView.playButton.addTarget(self, action: #selector(playPressed(sender:)), for: .touchUpInside)
		
		self.nextButton.addTarget(self, action: #selector(nextTrackButtonPressed(_:)), for: .touchUpInside)
		self.playerView.trackChangeButtons.next.addTarget(self, action: #selector(nextTrackButtonPressed(_:)), for: .touchUpInside)
		
		self.playerView.trackChangeButtons.prev.addTarget(self, action: #selector(prevTrackButtonPressed(_:)), for: .touchUpInside)
		
		self.playerView.trackSeekButtons.forw.addTarget(self, action: #selector(remoteRightButtonPressed(_:)), for: .touchUpInside)
		self.playerView.trackSeekButtons.backw.addTarget(self, action: #selector(remoteLeftButtonPressed(_:)), for: .touchUpInside)
		
		self.playerView.trackProgressView.addTarget(self, action: #selector(trackSeekChanged(_:)), for: .touchUpInside)
		
		playlistView.tableView.tableHeaderView = self.playerView
		
		self.view.addSubview(playlistView)
		playlistView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		playlistView.tableView.scrollIndicatorInsets.top = 54
		
		let topBar = UIView()
		topBar.backgroundColor = .white
		self.view.addSubview(topBar)
		topBar.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(64)
		}
		
		AudioController.main.delegate = self
	}
	
	func showPlaylist() {
		if self.playlistView.tracks[0].count != 0 {
			self.playlistView.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
		} else if self.playlistView.tracks[1].count != 0 {
			self.playlistView.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 1), at: .top, animated: true)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("132")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		playerView.snp.makeConstraints { (make) in
			make.size.equalTo(self.view.frame.size)
		}
		self.view.layoutIfNeeded()
	}
	
	@objc func trackSeekChanged(_ sender: Any) {
		audioController.make(command: .seek(progress: Double(self.playerView.trackProgressView.slider.value)))
	}
	
	@objc func playPressed(sender: UIButton) {
		if audioController.status == .playing {
			audioController.make(command: .pause)
		} else {
			audioController.make(command: .play(id: nil))
		}
	}
	
	@objc func remoteLeftButtonPressed(_ sender: Any) {
		audioController.make(command: .seekBackward)
	}
	
	@objc func remoteRightButtonPressed(_ sender: Any) {
		audioController.make(command: .seekForward)
	}
	
	@objc func prevTrackButtonPressed(_ sender: Any) {
		audioController.make(command: .prev)
	}
	
	@objc func nextTrackButtonPressed(_ sender: Any) {
		audioController.make(command: .next)
	}
	
	func updateTime(time: (current: Double, length: Double)) {
		DispatchQueue.main.async {
			self.popupItem.progress = Float(time.current / time.length)
			if !self.playerView.trackProgressView.slider.isHighlighted {
				self.playerView.trackProgressView.slider.value = Float(time.current / time.length)
			}
			self.playerView.trackProgressView.trackProgressLabels.start.text = Int64(time.current).formatTime()
			self.playerView.trackProgressView.trackProgressLabels.fin.text = "-" + Int64(abs(time.length - time.current)).formatTime()
		}
	}
	
	func volumeUpdate(value: Double) {
	}
	
	func playState(isPlaying: Bool) {
		self.playerView.playButton.isSelected = isPlaying
		self.playButton.isSelected = isPlaying
	}
	
	func trackUpdate() {
		DispatchQueue.main.async {
			if let ob = self.audioController.currentTrack {
				let channel = ob.author
				let title = ob.name

				self.popupItem.title = channel
				self.popupItem.subtitle = title
				self.playerView.channelNameLabel.text = channel
				self.playerView.trackNameLabel.text = title
				if let url = ob.imageURL {
					self.playerView.coverImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: { (img, error, type, url) in
						self.popupItem.image = img
						self.playerView.setPicture(image: img)
					})
				}
			}
			if self.audioController.status != .playing {
				let info = self.audioController.info
				UIView.animate(withDuration: 0.01, animations: {
					self.playerView.trackProgressView.slider.value = Float(info.current/info.length)
					self.playerView.trackProgressView.trackProgressLabels.start.text = Int64(info.current).formatTime()
					self.playerView.trackProgressView.trackProgressLabels.fin.text = "-" + Int64(abs(info.length - info.current)).formatTime()
					
					self.popupItem.progress = 0
				})
			}
			self.playlistView.currentIndex = self.audioController.currentTrackIndexPath
			self.playlistView.tableView.reloadData()
			self.playerView.isHidden = false
		
		}
//		self.playButton.isSelected = audioController.status == .playing
//		self.playerView.playButton.isSelected = audioController.status == .playing
	}
	
	func playlistChanged() {
		self.popupItem.title = ""
		self.popupItem.subtitle = ""
		self.playerView.channelNameLabel.text = ""
		self.playerView.trackNameLabel.text = ""
		self.playerView.coverImageView.image = nil
		
		self.playlistView.tracks = [self.audioController.userPlaylist.tracks, self.audioController.playlist.tracks]
		self.playlistView.currentIndex = self.audioController.currentTrackIndexPath
		self.playlistView.tableView.reloadData()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
