
import UIKit
import SnapKit
import SwiftyAudioManager

class NewFeedTableViewCell: UITableViewCell {

	public static let cellID: String = "NewFeedCellID"
	
	let iconImageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 10
		imageView.backgroundColor = .red
		imageView.snp.makeConstraints({ (maker) in
			maker.width.equalTo(20)
			maker.height.equalTo(20)
		})
		return imageView
	}()
	
	let channelLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
		label.textColor = UIColor.init(white: 2/255.0, alpha: 1)
		label.textAlignment = .left
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 1
		label.text = "123 123 123"
		return label
	}()

	let timeAgoLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
		label.textColor = UIColor.init(white: 74/255.0, alpha: 1)
		label.textAlignment = .right
		label.text = "9 days ago"
		return label
	}()

	let mainPictureImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage.init(named: "channelPrevievImg")
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 9.0
		imageView.layer.borderWidth = 1.0
		imageView.layer.borderColor = UIColor.init(red: 1, green: 102.0/255, blue: 102.0/255, alpha: 0.06).cgColor
		return imageView
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 5
		label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
		label.textColor = .white
		label.lineBreakMode = .byTruncatingTail
		label.textAlignment = .left
		return label
	}()
	
	var dataLabels: [IconLabelType: IconedLabel] = [:]
	
	let likeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage.init(named: "likeActiveFeed") , for: .selected)
		button.setImage(UIImage.init(named: "likeInactiveFeed"), for: .normal)
		return button
	}()
	
	let playButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage.init(named: "playFeed"), for: .normal)
		button.setImage(UIImage.init(named: "pauseFeed"), for: .selected)
		button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
		return button
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.selectionStyle = .none
		
		viewInitialize()
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerPaused(_:)),
											   name: AudioManagerNotificationName.paused.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerStartPlaying(_:)),
											   name: AudioManagerNotificationName.startPlaying.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerPaused(_:)),
											   name: AudioManagerNotificationName.endPlaying.notification,
											   object: audioManager)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(audioManagerStartPlaying(_:)),
											   name: AudioManagerNotificationName.resumed.notification,
											   object: audioManager)
		
		self.playButton.addTarget(self, action: #selector(playPressed(_:)), for: .touchUpInside)
		self.likeButton.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
	}
	
	@objc func playPressed(_: UIButton){
		if track != nil {
			onPlay?(track!.uniqString())
		}
	}
	
	@objc func likePressed(_: UIButton) {
		likeButton.isSelected = !likeButton.isSelected
		if track != nil {
			onLike?(track!.id)
		}
	}
	
	// MARK: - AudioManager events
	@objc func audioManagerStartPlaying(_ notification: Notification) {
		playButton.isSelected = audioManager.currentItemId == track?.uniqString()
	}
	
	@objc func audioManagerPaused(_ notification: Notification) {
		playButton.isSelected = false
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	let audioManager = AppManager.shared.audioManager
	public var onPlay: ((String) -> Void)?
	public var onLike: ((Int) -> Void)?
	
	
	weak var track: Track? = nil {
		didSet {
			titleLabel.text = track?.name
			channelLabel.text = track?.findStationName()
			
			if let iconUrl = track?.findChannelImage() {
				iconImageView.sd_setImage(with: iconUrl)
			} else {
				iconImageView.image = nil
			}
			
			if let iconUrl = track?.image.buildImageURL() {
				mainPictureImageView.sd_setImage(with: iconUrl)
			} else {
				mainPictureImageView.image = nil
			}
			let maxTime = track?.audiofile?.lengthSeconds ?? 0

			dataLabels[.likes]?.setData(data: Int64(track?.likeCount ?? 0))
			dataLabels[.listens]?.setData(data: Int64(track?.likeCount ?? 0))
			dataLabels[.time]?.setData(data: maxTime)
			
			likeButton.isSelected = LikeManager.shared.hasObject(id: track?.id ?? 0)
			playButton.isSelected = audioManager.isPlaying && audioManager.currentItemId == track?.uniqString()
		}
	}
	
	func viewInitialize() {
		self.contentView.addSubview(mainPictureImageView)
		mainPictureImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		let topBlur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.extraLight))
		let bottomBlur = UIVisualEffectView.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.extraLight))
		
		mainPictureImageView.addSubview(topBlur)
		topBlur.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(32)
		}
		
		mainPictureImageView.addSubview(bottomBlur)
		bottomBlur.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(32)
		}
		
		topBlur.contentView.addSubview(iconImageView)
		iconImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
		}
		
		topBlur.contentView.addSubview(channelLabel)
		channelLabel.snp.makeConstraints { (make) in
			make.left.equalTo(iconImageView.snp.right).inset(-6)
			make.centerY.equalToSuperview()
		}
		
		topBlur.contentView.addSubview(timeAgoLabel)
		timeAgoLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.width.equalTo(88)
			make.left.equalTo(channelLabel.snp.right).inset(-8)
		}
		
		let time = IconedLabel.init(type: .time)
		bottomBlur.contentView.addSubview(time)
		time.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(8)
			make.centerY.equalToSuperview()
		}
		
		let likes = IconedLabel.init(type: .likes)
		bottomBlur.contentView.addSubview(likes)
		likes.snp.makeConstraints { (make) in
			make.left.equalTo(time.snp.right).inset(-4)
			make.centerY.equalToSuperview()
		}
		
		let listens = IconedLabel.init(type: .listens)
		bottomBlur.contentView.addSubview(listens)
		listens.snp.makeConstraints { (make) in
			make.left.equalTo(likes.snp.right).inset(-4)
			make.centerY.equalToSuperview()
		}
		
		self.dataLabels = [.time: time, .likes: likes, .listens: listens]
		
		let playBlurView = UIVisualEffectView(effect: UIBlurEffect.init(style: .extraLight))
		
		playBlurView.contentView.addSubview(self.playButton)
		self.playButton.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		mainPictureImageView.addSubview(playBlurView)
		playBlurView.snp.makeConstraints { (make) in
			make.centerY.equalTo(bottomBlur.snp.top)
			make.right.equalToSuperview().inset(10)
			make.width.equalTo(50)
			make.height.equalTo(50)
		}
		playBlurView.layer.masksToBounds = true
		playBlurView.layer.cornerRadius = 25
		
		let likeBlurView = UIVisualEffectView(effect: UIBlurEffect.init(style: .extraLight))
		likeBlurView.contentView.addSubview(self.likeButton)
		self.likeButton.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		mainPictureImageView.addSubview(likeBlurView)
		likeBlurView.snp.makeConstraints { (make) in
			make.bottom.equalTo(playBlurView.snp.top).inset(-16)
			make.centerX.equalTo(playBlurView)
			make.width.equalTo(36)
			make.height.equalTo(36)
		}
		likeBlurView.layer.masksToBounds = true
		likeBlurView.layer.cornerRadius = 18
	}

	required init?(coder aDecoder: NSCoder) {
		return nil
	}

}

enum IconLabelType: String {
	case time = "timeCount", comments = "commentCount", likes = "likesCount", listens = "listensCount"
}

class IconedLabel: UIView {
	var type: IconLabelType = .likes
	private var textLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.init(white: 74.0/255, alpha: 1)
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textAlignment = .left
		label.text = "123"
		return label
	}()
	
	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	init(type: IconLabelType) {
		super.init(frame: .zero)
		
		self.type = type
		self.iconImageView.image = UIImage.init(named: type.rawValue)
		
		self.addSubview(iconImageView)
		iconImageView.snp.makeConstraints { (make) in
			make.width.equalTo(16)
			make.height.equalTo(16)
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		self.addSubview(textLabel)
		textLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.left.equalTo(iconImageView.snp.right).inset(-4)
			make.centerY.equalToSuperview()
		}
	}
	
	func setData(data: Int64) {
		if self.type == .time {
			self.textLabel.text = "\(data.formatTime())"
		} else {
			self.textLabel.text = "\(data.formatAmount())"
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
}
