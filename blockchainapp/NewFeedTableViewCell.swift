
import UIKit
import SnapKit
import SwipeCellKit

class NewFeedTableViewCell: UITableViewCell {//SwipeTableViewCell {

	public static let cellID: String = "NewFeedCellID"
	
	public var onPlay: ((Int) -> Void)?
	public var onLike: ((Int) -> Void)?
	
	weak var track: Track? = nil {
		didSet {
			if let iconUrl = track?.findChannelImage() {
				iconImageView.sd_setImage(with: iconUrl)
			} else {
				iconImageView.image = nil
			}
			
			if let url = URL(string: track?.image) {
				mainPictureImageView.sd_setImage(with: url)
			} else {
				mainPictureImageView.image = nil
			}
			
			trackTitleLabel.attributedText = type(of: self).title(text: track?.name ?? "")
//            infoTitle.text = track?.name ?? ""
//            infoText.text = track?.desc ?? ""
//			trackTitleLabel.text = track?.name ?? ""
			channelLabel.text = track?.findStationName()
			
			timeAgoLabel.text = track?.publishedAt.formatString()
			
			dataLabels[.likes]?.setData(data: Int64(track?.likeCount ?? 0))
			dataLabels[.listens]?.setData(data: Int64(track?.listenCount ?? 0))
			dataLabels[.time]?.setData(data: track?.length ?? 0)
			
			likeButton.isSelected = LikeManager.shared.hasObject(id: track?.id ?? 0)
//			playButton.isSelected = audioManager.isPlaying && audioManager.currentItemId == track?.uniqString()
            
//            infoTitle.text = track?.name
//            infoText.text = track?.desc
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		viewInitialize()
        
//		self.playButton.addTarget(self, action: #selector(playPressed(_:)), for: .touchUpInside)
		self.likeButton.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
	}
	
	@objc func playPressed(_: UIButton){
//		if let id = track?.id {
			onPlay?(0)
//		}
	}
	
	@objc func likePressed(_: UIButton) {
		likeButton.isSelected = !likeButton.isSelected
//		if let id = track?.id {
			onLike?(0)
//		}
	}
	
	func set(isPlaying: Bool) {
		self.dataLabels[.playingIndicator]?.isHidden = !isPlaying
		self.dataLabels[.listens]?.isHidden = isPlaying
	}
	
	static func title(text: String, calc: Bool = false) -> NSAttributedString {
		let para = NSMutableParagraphStyle()
		para.lineBreakMode = .byWordWrapping
		para.minimumLineHeight = 22
		para.maximumLineHeight = 22
		return NSAttributedString.init(string: text , attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: AppColor.Title.dark, .paragraphStyle: para])
	}
	
	static func height(text: String, width: CGFloat) -> CGFloat {
		let picHeight = ceil((width - 32)*9.0/16.0)
		let textHeight = title(text: text, calc: true)
			.boundingRect(with: CGSize.init(width: width - 20 - 32, height: 999), options: .usesLineFragmentOrigin, context: nil)
			.height
		return min(66, ceil(textHeight)) + picHeight + 32 + 4 + 32 + 24 + 2
	}
	
	// MARK: - AudioManager events
//	@objc func audioManagerStartPlaying(_ notification: Notification) {
//		playButton.isSelected = audioManager.currentItemId == track?.uniqString()
//	}
//
//	@objc func audioManagerPaused(_ notification: Notification) {
//		playButton.isSelected = false
//	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	let iconImageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
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
		imageView.layer.masksToBounds = true
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 3
		label.lineBreakMode = .byWordWrapping
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		label.textColor = AppColor.Title.dark
		return label
	}()
	
	var dataLabels: [IconLabelType: IconedLabel] = [:]
	
	let likeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage.init(named: "likeActiveFeed") , for: .selected)
		button.setImage(UIImage.init(named: "likeInactiveFeed"), for: .normal)
		return button
	}()
	
	let trackTitleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 3
		return label
	}()
    
//    let infoBlurView: UIVisualEffectView = {
//        var blurView = UIVisualEffectView()
//        blurView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
//        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurView.clipsToBounds = true
//        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//        return blurView
//    }()
    
//    let infoTitle: UILabel = {
//       let label = UILabel()
//        label.font = AppFont.Title.sml
//        label.textColor = .black
//        label.backgroundColor = .clear
//        label.lineBreakMode = NSLineBreakMode.byWordWrapping
//        label.numberOfLines = 2
//        label.text = "Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго "
//        label.sizeToFit()
//        return label
//    }()
    
//    let infoText: UITextView = {
//        let textView = UITextView()
//        textView.font = AppFont.Title.info
//        textView.textColor = .black
//        textView.backgroundColor = .clear
//        textView.isEditable = false
//        textView.isSelectable = false
//        textView.text = "Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин  Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин "
//        return textView
//    }()
    
    let alertBlurView: UIVisualEffectView = {
        let alert = UIVisualEffectView(effect: UIBlurEffect.init(style: .light))
        alert.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alert.clipsToBounds = true
        alert.layer.cornerRadius = 10
        return alert
    }()
    
    let alertLabel: UILabel = {
        let alert = UILabel()
        alert.font = AppFont.Title.big
        alert.textAlignment = .center
        alert.text = "Трек добавлен"
        return alert
    }()
        
	func viewInitialize() {
		
		self.selectionStyle = .none
        self.backgroundColor = .white
        self.backgroundView?.backgroundColor = .white
        self.tintColor = .white
		
		let cellContentView = UIView()
		cellContentView.layer.masksToBounds = true
		cellContentView.layer.cornerRadius = 9.0
		cellContentView.layer.borderWidth = 1.0
		cellContentView.layer.borderColor = UIColor.init(white: 151.0/255, alpha: 0.06).cgColor
		cellContentView.backgroundColor = UIColor.init(white: 240.0/255, alpha: 1)

		self.contentView.addSubview(cellContentView)
		cellContentView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.right.equalToSuperview().inset(16)
			make.top.equalToSuperview().inset(24)
			make.bottom.equalToSuperview()
		}
		
		cellContentView.addSubview(mainPictureImageView)
		mainPictureImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview().inset(32)
			make.width.equalTo(mainPictureImageView.snp.height).multipliedBy(16.0/9)
		}
		
		
		cellContentView.addSubview(iconImageView)
		iconImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(10)
			make.top.equalToSuperview().inset(6)
		}
		
		cellContentView.addSubview(channelLabel)
		channelLabel.snp.makeConstraints { (make) in
			make.left.equalTo(iconImageView.snp.right).inset(-6)
			make.centerY.equalTo(iconImageView)
		}
		
		cellContentView.addSubview(timeAgoLabel)
		timeAgoLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalTo(iconImageView)
			make.width.equalTo(88)
			make.left.equalTo(channelLabel.snp.right).inset(-8)
		}
		
		let time = IconedLabel.init(type: .time)
		cellContentView.addSubview(time)
		time.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(8)
			make.bottom.equalToSuperview().inset(8)
		}
		
		let likes = IconedLabel.init(type: .likes)
		cellContentView.addSubview(likes)
		likes.snp.makeConstraints { (make) in
			make.left.equalTo(time.snp.right).inset(-4)
			make.centerY.equalTo(time)
		}
		
		let listens = IconedLabel.init(type: .listens)
		cellContentView.addSubview(listens)
		listens.snp.makeConstraints { (make) in
			make.left.equalTo(likes.snp.right).inset(-4)
			make.centerY.equalTo(time)
		}
		
		let playingIndicator = IconedLabel.init(type: .playingIndicator)
		cellContentView.addSubview(playingIndicator)
		playingIndicator.snp.makeConstraints { (make) in
			make.left.equalTo(likes.snp.right).inset(-4)
			make.centerY.equalTo(time)
		}
		playingIndicator.isHidden = true
		
		self.dataLabels = [.time: time, .likes: likes, .listens: listens, .playingIndicator: playingIndicator]
		
		cellContentView.addSubview(trackTitleLabel)
		trackTitleLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(10)
			make.top.equalTo(mainPictureImageView.snp.bottom).inset(-4)
			make.bottom.equalToSuperview().inset(32)
			make.right.equalToSuperview().inset(10)
		}
		
		let likeBlurView = UIVisualEffectView(effect: UIBlurEffect.init(style: .extraLight))
		likeBlurView.contentView.addSubview(self.likeButton)
		self.likeButton.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		cellContentView.addSubview(likeBlurView)
		likeBlurView.snp.makeConstraints { (make) in
			make.bottom.equalTo(mainPictureImageView).inset(10)
			make.right.equalTo(mainPictureImageView).inset(10)
			make.width.equalTo(36)
			make.height.equalTo(36)
		}
		likeBlurView.layer.masksToBounds = true
		likeBlurView.layer.cornerRadius = 18
        
//        self.infoBlurView.contentView.addSubview(infoTitle)
//        infoTitle.snp.makeConstraints { (make) in
//            make.top.equalTo(infoBlurView).inset(10)
//            make.left.equalTo(infoBlurView).inset(10)
//            make.right.equalTo(infoBlurView).inset(10)
////            make.height.equalTo(infoTitle.frame.size.height)
//        }
//
//        self.infoBlurView.contentView.addSubview(infoText)
//        infoText.snp.makeConstraints { (make) in
//            make.top.equalTo(infoTitle.snp.bottom).inset(-12)
//            make.bottom.equalTo(infoBlurView).inset(10)
//            make.left.equalTo(infoBlurView).inset(10)
//            make.right.equalTo(infoBlurView).inset(10)
//        }
//        infoText.setContentHuggingPriority(.init(999), for: .vertical)
//
//        cellContentView.addSubview(infoBlurView)
//        infoBlurView.snp.makeConstraints { (make) in
//            make.bottom.equalTo(cellContentView)
//            make.right.equalTo(cellContentView)
//            make.width.equalTo(cellContentView)
//            make.height.equalTo(cellContentView)
//        }
//
//        infoBlurView.alpha = 0
        
//        let sizeOfText = yourText sizeWithFont:yourFont constrainedToSize:CGSizeMake(constrainedWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap
        let sizeOfText: CGSize = alertLabel.text!.size(withAttributes: [NSAttributedStringKey.font: AppFont.Title.big])
        
        cellContentView.addSubview(alertBlurView)
        alertBlurView.snp.makeConstraints{ (make) in
            make.centerX.equalTo(mainPictureImageView.snp.centerX)
            make.centerY.equalTo(mainPictureImageView.snp.centerY)
            make.width.equalTo(sizeOfText.width + 40)
            make.height.equalTo(128)
        }
        
        self.alertBlurView.contentView.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.centerX.equalTo(alertBlurView.snp.centerX)
        }
        
        let imageView = UIImageView.init(image: UIImage(named: "completeIcon"))
        
        self.alertBlurView.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(alertBlurView.snp.centerX)
            make.width.equalTo(54)
            make.height.equalTo(54)
            make.top.equalTo(alertLabel.snp.bottom).inset(-14)
        }
        
        alertBlurView.alpha = 0
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
	
//	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//		let likePoint = self.convert(point, to: likeButton)
////		let playPoint = self.convert(point, to: playButton)
//		if likeButton.frame.contains(likePoint) {
//			return likeButton
//		}
////		if playButton.frame.contains(playPoint) {
////			return playButton
////		}
//		return super.hitTest(point, with: event)
//	}

//    func getInfo(toHide: Bool, animated: Bool)
//    {
//        if toHide
//        {
//            if animated
//            {
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.infoBlurView.alpha = 0
//                })
//            }
//            else
//            {
//                self.infoBlurView.alpha = 0
//            }
//        }
//        else
//        {
//            self.infoText.setContentOffset(.zero, animated: false)
//            UIView.animate(withDuration: 0.5, animations: {
//                self.infoBlurView.alpha = 1
//            })
//        }
//    }
}
