//
//  MainPlayerViewController.swift
//  blockchainapp
//
//  Created by Aleksey Tyurnin on 25/01/2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer
import AssistantKit
import MarqueeLabel
import SDWebImage

class PlayerViewController: UIViewController, PlayerViewDelegate {

    weak var miniPlayer: MiniPlayerView?
    var viewModel: PlayerViewModel!
    var emitter: PlayerEmitter!

    init() { super.init(nibName: nil, bundle: nil) }

    init(viewModel: PlayerViewModel, emitter: PlayerEmitter) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
        self.emitter = emitter
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

		viewInitialize()
    }
	

	@objc func seek() {
//		AudioController.main.make(command: .seek(progress: Double(self.trackProgressView.slider.value)))
        self.emitter.send(event: .seek(progress: Double(self.trackProgressView.slider.value)))
	}

	@objc func buttonPressed(sender: UIButton) {
        var event: PlayerEvent!
        switch sender.tag {
            case 1,2:
                event = .change(dir: sender.tag == 1 ? .backward : .forward)
            case 3,4:
                event = .seekDir(dir: sender.tag == 3 ? .backward : .forward)
            default:
                event = .plause
        }
        self.emitter.send(event: event)
	}

    func updateButtons() {
        let dict = self.viewModel.status
        for tuple in dict {
            switch tuple.key {
            case .isPlaying:
                self.playButton.isSelected = tuple.value
				self.miniPlayer?.playButton.isSelected = tuple.value
            case .canBackward:
                self.trackChangeButtons.prev.isEnabled = tuple.value
            case .canForward:
                self.trackChangeButtons.next.isEnabled = tuple.value
				self.miniPlayer?.nextButton.isEnabled = tuple.value
            }
        }
    }

    func updateTime() {
        let time = self.viewModel.currentTimeState
        self.trackProgressView.trackProgressLabels.start.text = time.past
        self.trackProgressView.trackProgressLabels.fin.text = time.future
    }

    func updateTrack() {
        let track = self.viewModel.track
        if let url = track.imageURL {
            self.coverImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: { (img, error, type, url) in
                self.setPicture(image: img)
            })
        } else {
            self.setPicture(image: nil)
        }
        self.channelNameLabel.text = track.author
        self.trackNameLabel.text = track.name
        self.miniPlayer?.trackNameLabel.text = track.name
        self.miniPlayer?.trackAuthorLabel.text = track.name
    }

    func setPicture(image: UIImage?) {
		self.underBlurImageView.image = image
		self.coverImageView.image = image
        self.miniPlayer?.trackImageView.image = image

        guard let image = image else {
			return
		}

		let isSquare = image.size.width / image.size.height < 1.3
		

		self.squareConstraint?.isActive = isSquare
		self.landscapeConstraint?.isActive = !isSquare

		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.view.layoutIfNeeded()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.shadowLayer.shadowPath = UIBezierPath.init(
                roundedRect: CGRect.init(
                        origin: CGPoint.zero,
                        size: underBlurImageView.frame.size),
                cornerRadius: 7).cgPath
		self.shadowLayer.frame = self.underBlurImageView.frame
		self.channelNameLabel.fadeLength = 16
		self.trackNameLabel.fadeLength = 16
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let underBlurImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = false

        return imageView
    }()
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 7
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true

        imageView.isUserInteractionEnabled = false

        return imageView
    }()
    var squareConstraint: LayoutConstraint?
    var landscapeConstraint: LayoutConstraint?
    let shadowLayer: CALayer = {
        let layer = CALayer()

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.3
        layer.shouldRasterize = true

        return layer
    }()

    let trackProgressView: TimedSlider = TimedSlider(frame: CGRect.zero)
    let channelNameLabel: MarqueeLabel = {
        let label = MarqueeLabel(frame: CGRect.zero, duration: 16.0, fadeLength: 16)
        label.font = AppFont.Title.mid
        label.textColor = AppColor.Title.dark
        label.textAlignment = .center
        return label
    }()
    let trackNameLabel: MarqueeLabel = {
        let label = MarqueeLabel(frame: CGRect.zero, duration: 16.0, fadeLength: 16)
        label.font = AppFont.Title.midBold
        label.textColor = AppColor.Title.dark
        label.textAlignment = .center
        return label
    }()
    let playButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIColor.red.img(), for: .normal)
        button.setBackgroundImage(UIColor.red.withAlphaComponent(0.7).img(), for: .highlighted)
        button.setImage(UIImage(named: "playerPlay"), for: .normal)
        button.setImage(UIImage(named: "playerPause"), for: .selected)
        button.adjustsImageWhenHighlighted = false
        button.layer.cornerRadius = Device.screen == .inches_4_0 ? 27.5 : 35
        button.layer.masksToBounds = true
        button.tag = 0
        button.snp.makeConstraints({ (make) in
            make.width.equalTo(button.snp.height)
        })
        return button
    }()
    let trackChangeButtons: (next: UIButton, prev: UIButton) = {
        let arr = [UIButton(), UIButton()]
        arr.forEach({ (button) in
            button.layer.cornerRadius = Device.screen == .inches_4_0 ? 22.5 : 30
            button.imageView?.contentMode = .scaleAspectFit
            button.snp.makeConstraints({ (make) in
                make.width.equalTo(button.snp.height)
            })
        })
        for i in 0..<arr.count {
            arr[i].tag = i + 1
        }
        arr.first!.setImage(UIImage(named: "nextInactive"), for: .normal)
        arr.last!.setImage(UIImage(named: "prevInactive"), for: .normal)

        return (next: arr.first!, prev: arr.last!)
    }()

    let trackSeekButtons: (forw: UIButton, backw: UIButton) = {
        let arr = [UIButton(), UIButton()]
        arr.forEach({ (button) in
            button.layer.cornerRadius = Device.screen == .inches_4_0 ? 22.5 : 30
            button.imageView?.contentMode = .scaleAspectFit
            button.snp.makeConstraints({ (make) in
                make.width.equalTo(button.snp.height)
            })
        })
        for i in 0..<arr.count {
            arr[i].tag = i + 3
        }
        arr.first!.setImage(UIImage(named: "playerForw"), for: .normal)
        arr.last!.setImage(UIImage(named: "playerBackw"), for: .normal)

        return (forw: arr.first!, backw: arr.last!)
    }()

    func viewInitialize() {

        self.view.backgroundColor = UIColor.white

        self.view.addSubview(underBlurImageView)
        underBlurImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
        }

        let blur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        self.view.addSubview(blur)
        blur.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        blur.contentView.addSubview(trackProgressView)

        let imageSpacer = UIView()
        blur.contentView.addSubview(imageSpacer)
        imageSpacer.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(52)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.trackProgressView.snp.top)
        }

        imageSpacer.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in

            make.centerY.equalToSuperview()

            make.right.equalToSuperview().inset(30)
            make.left.equalToSuperview().inset(30)
            self.squareConstraint = make.height.equalTo(coverImageView.snp.width).multipliedBy(1.0).constraint.layoutConstraints.first
            self.landscapeConstraint = make.height.equalTo(coverImageView.snp.width).multipliedBy(9.0/16).constraint.layoutConstraints.first


            make.top.equalTo(underBlurImageView.snp.top)
            make.size.equalTo(underBlurImageView.snp.size)
        }

        let volumeSlider: MPVolumeView = {
            let slider = MPVolumeView()
            slider.setMinimumVolumeSliderImage(AppColor.Element.subscribe.img(), for: .normal)
            slider.setMaximumVolumeSliderImage(AppColor.Element.subscribe.withAlphaComponent(0.2).img(), for: .normal)
            slider.showsRouteButton = false
            return slider
        }()

        let minVol = UIImageView(image: UIImage(named: "volMin"))
        let maxVol = UIImageView(image: UIImage(named: "volMax"))

        blur.contentView.addSubview(minVol)
        minVol.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(30)
        }

        blur.contentView.addSubview(volumeSlider)
        volumeSlider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(Device.screen == .inches_4_0 ? 10 : 26)
            make.left.equalTo(minVol.snp.right).inset(-8)
            make.centerY.equalTo(minVol)
            make.height.equalTo(20)
        }
        volumeSlider.setContentHuggingPriority(.init(999), for: .horizontal)

        blur.contentView.addSubview(maxVol)
        maxVol.snp.makeConstraints { (make) in
            make.left.equalTo(volumeSlider.snp.right).inset(-8)
            make.right.equalToSuperview().inset(31)
            make.centerY.equalTo(volumeSlider)
        }

        blur.contentView.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(volumeSlider.snp.top).inset(Device.screen == .inches_4_0 ? -15 : -20)

            make.width.equalTo(Device.screen == .inches_4_0 ? 55 : 70)
        }

        blur.contentView.addSubview(trackSeekButtons.backw)
        trackSeekButtons.backw.snp.makeConstraints { (make) in
            make.centerY.equalTo(playButton)
            make.right.equalTo(playButton.snp.left).inset(-12)

            make.width.equalTo(playButton.snp.width).inset(10)
        }

        blur.contentView.addSubview(trackSeekButtons.forw)
        trackSeekButtons.forw.snp.makeConstraints { (make) in
            make.centerY.equalTo(playButton)
            make.left.equalTo(playButton.snp.right).inset(-12)
            make.width.equalTo(playButton.snp.width).inset(10)
        }

        blur.contentView.addSubview(trackChangeButtons.next)
        trackChangeButtons.next.snp.makeConstraints { (make) in
            make.centerY.equalTo(playButton)
            make.left.equalTo(trackSeekButtons.forw.snp.right).inset(-12)
            make.width.equalTo(playButton.snp.width).inset(10)
        }

        blur.contentView.addSubview(trackChangeButtons.prev)
        trackChangeButtons.prev.snp.makeConstraints { (make) in
            make.centerY.equalTo(playButton)
            make.right.equalTo(trackSeekButtons.backw.snp.left).inset(-12)
            make.width.equalTo(playButton.snp.width).inset(10)
        }

        blur.contentView.addSubview(trackNameLabel)
        trackNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(playButton.snp.top).inset(Device.screen == .inches_4_0 ? -10 : -20)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }

        blur.contentView.addSubview(channelNameLabel)
        channelNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalTo(trackNameLabel.snp.top)
        }

        trackProgressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(33)
            make.right.equalToSuperview().inset(33)
            make.bottom.equalTo(channelNameLabel.snp.top).inset(-7)
        }
        trackProgressView.setContentHuggingPriority(.init(999), for: .horizontal)

        trackProgressView.addTarget(self, action: #selector(seek), for: .valueChanged)
        playButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        trackChangeButtons.next.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        trackChangeButtons.prev.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        trackSeekButtons.backw.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        trackSeekButtons.forw.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
    }

}
