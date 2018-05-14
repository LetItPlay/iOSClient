
import UIKit
import SnapKit
import SwipeCellKit
import RxSwift
import SDWebImage

class FeedTableViewCell: SwipeTableViewCell, StandartTableViewCell {

	public static let cellID: String = "NewFeedCellID"
	
	public var onLike: ((Int) -> Void)?
    public var onChannel: ((Int) -> Void)?
    public var onOthers: (() -> Void)?

	var disposeBag = DisposeBag()
	
    func fill(vm: TrackViewModel) {
        self.channelLabel.text = vm.author
        if let authorImage = vm.authorImage {
            self.channelImageView.sd_setImage(with: authorImage, placeholderImage: UIImage(named: "channelPreviewImg"), options: SDWebImageOptions.refreshCached, completed: nil)
        } else {
            self.channelImageView.image = UIImage(named: "channelPreviewImg")
        }
    
        self.timeAgoLabel.text = vm.dateString
    
        self.trackTitleLabel.attributedText = type(of: self).title(text: vm.name)
        if let trackImage = vm.imageURL {
            self.mainPictureImageView.sd_setImage(with: trackImage, placeholderImage: UIImage(named: "trackPlaceholder"), options: SDWebImageOptions.refreshCached, completed: nil)
        } else {
            self.mainPictureImageView.image = UIImage(named: "trackPlaceholder")
        }
    
        self.infoTitle.text = vm.name
    
        var trackDescription = NSMutableAttributedString()
    
        do {
            var dict: NSDictionary? = [NSAttributedStringKey.font : AppFont.Text.descr]
            trackDescription = try NSMutableAttributedString(data: vm.description.data(using: .utf16)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: &dict)
            trackDescription.addAttribute(NSAttributedStringKey.font, value: AppFont.Text.descr, range: NSRange(location: 0, length: trackDescription.length))
        } catch (let error) {
            print(error)
        }
    
        self.infoTextView.attributedText = trackDescription
    
        self.disposeBag = DisposeBag()
    
        self.dataLabels[.likes]?.set(text: vm.likesCount)
    
        self.dataLabels[.listens]?.set(text: vm.listensCount)
    
        self.dataLabels[.playingIndicator]?.isHidden = !vm.isPlaying
        self.dataLabels[.listens]?.isHidden = vm.isPlaying
        
//            self.showOthersButton.isHidden = vm.isPlaying
    
        self.likeButton.isSelected = vm.isLiked
    
        self.dataLabels[.time]?.set(text: vm.length)
    
        self.alertBlurView.alpha = 0
    }
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.viewInitialize()
    }
    
    func fill(data: Any?) {
        guard let vm = data as? TrackViewModel else {
            return
        }
        self.fill(vm: vm)
    }
    
    var event: ((String, [String : Any]?) -> Void)?
    
    static func height(data: Any, width: CGFloat) -> CGFloat {
        guard let vm = data as? TrackViewModel else {
            return 44.0
        }
        let picHeight = ceil((width - 32)*9.0/16.0)
        let textHeight = title(text: vm.name, calc: true)
            .boundingRect(with: CGSize.init(width: width - 20 - 32, height: 999), options: .usesLineFragmentOrigin, context: nil)
            .height
        return min(66, ceil(textHeight)) + picHeight + 32 + 4 + 32 + 24 + 2
    }

	static func title(text: String, calc: Bool = false) -> NSAttributedString {
		let para = NSMutableParagraphStyle()
		para.lineBreakMode = .byWordWrapping
		para.minimumLineHeight = 22
		para.maximumLineHeight = 22
		return NSAttributedString.init(string: text , attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: AppColor.Title.dark, .paragraphStyle: para])
	}
//
//    static func height(vm: TrackViewModel, width: CGFloat) -> CGFloat {
//        let picHeight = ceil((width - 32)*9.0/16.0)
//        let textHeight = title(text: vm.name, calc: true)
//            .boundingRect(with: CGSize.init(width: width - 20 - 32, height: 999), options: .usesLineFragmentOrigin, context: nil)
//            .height
//        return min(66, ceil(textHeight)) + picHeight + 32 + 4 + 32 + 24 + 2
//    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	let channelImageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
		imageView.snp.makeConstraints({ (maker) in
			maker.width.equalTo(20)
			maker.height.equalTo(20)
		})
        imageView.image = UIImage(named: "channelPreviewImg")
		return imageView
	}()
	
	let channelLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
		label.textColor = UIColor.init(white: 2/255.0, alpha: 1)
		label.textAlignment = .left
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 1
		return label
	}()
	
	let timeAgoLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
		label.textColor = UIColor.init(white: 74/255.0, alpha: 1)
		label.textAlignment = .right
		return label
	}()
	
	let mainPictureImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.masksToBounds = true
		imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "trackPlaceholder")
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
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		return button
	}()
	
	let trackTitleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 3
		return label
	}()
    
    let infoBlurView: UIVisualEffectView = {
        var blurView = UIVisualEffectView()
        blurView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.clipsToBounds = true
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return blurView
    }()
    
    let infoTitle: UILabel = {
       let label = UILabel()
        label.font = AppFont.Title.midBold
        label.textColor = .black
        label.backgroundColor = .clear
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = AppFont.Text.descr
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.blue, NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleNone.rawValue]
        return textView
    }()
    
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
        alert.text = "Track added".localized
        return alert
    }()
    
    var showOthersButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "otherInactive"), for: .normal)
        return button
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
		
		
		cellContentView.addSubview(channelImageView)
		channelImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(10)
			make.top.equalToSuperview().inset(6)
		}
		
		cellContentView.addSubview(channelLabel)
		channelLabel.snp.makeConstraints { (make) in
			make.left.equalTo(channelImageView.snp.right).inset(-6)
			make.centerY.equalTo(channelImageView)
		}
        
        let invisibleChannelButton = UIButton()
        invisibleChannelButton.alpha = 1
        invisibleChannelButton.addTarget(self, action: #selector(channelPressed), for: .touchUpInside)
        cellContentView.addSubview(invisibleChannelButton)
        invisibleChannelButton.snp.makeConstraints({ (make) in
            make.left.equalTo(channelImageView.snp.left)
            make.top.equalTo(channelImageView.snp.top)
            make.right.equalTo(channelLabel.snp.right)
            make.height.equalTo(channelImageView.snp.height)
        })
		
		cellContentView.addSubview(timeAgoLabel)
		timeAgoLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalTo(channelImageView)
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
			make.left.equalTo(time.snp.right).inset(-12)
			make.centerY.equalTo(time)
		}
		
		let listens = IconedLabel.init(type: .listens)
		cellContentView.addSubview(listens)
		listens.snp.makeConstraints { (make) in
			make.left.equalTo(likes.snp.right).inset(-12)
			make.centerY.equalTo(time)
		}
		
		let playingIndicator = IconedLabel.init(type: .playingIndicator)
		cellContentView.addSubview(playingIndicator)
		playingIndicator.snp.makeConstraints { (make) in
			make.left.equalTo(likes.snp.right).inset(-12)
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
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        likeBlurView.layer.masksToBounds = true
        likeBlurView.layer.cornerRadius = 25
        
        cellContentView.addSubview(showOthersButton)
        showOthersButton.snp.makeConstraints { (make) in
            make.height.equalTo(26)
            make.width.equalTo(26)
            make.right.equalTo(-8)
            make.bottom.equalTo(-8)
        }
        showOthersButton.isHidden = true
        
        self.infoBlurView.contentView.addSubview(infoTitle)
        infoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(infoBlurView).inset(10)
            make.left.equalTo(infoBlurView).inset(10)
            make.right.equalTo(infoBlurView).inset(10)
//            make.height.equalTo(infoTitle.frame.size.height)
        }

        self.infoBlurView.contentView.addSubview(infoTextView)
        infoTextView.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).inset(-12)
            make.bottom.equalTo(infoBlurView).inset(10)
            make.left.equalTo(infoBlurView).inset(7)
            make.right.equalTo(infoBlurView).inset(7)
        }
        infoTextView.setContentHuggingPriority(.init(999), for: .vertical)
        

        cellContentView.addSubview(infoBlurView)
        infoBlurView.snp.makeConstraints { (make) in
            make.bottom.equalTo(cellContentView)
            make.right.equalTo(cellContentView)
            make.width.equalTo(cellContentView)
            make.height.equalTo(cellContentView)
        }

        infoBlurView.alpha = 0
        
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
        
        self.likeButton.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
        self.showOthersButton.addTarget(self, action: #selector(showOthersButtonTouched), for: .touchUpInside)
	}
    
    
    @objc func likePressed(_: UIButton) {
        likeButton.isSelected = !likeButton.isSelected
        self.event?("onLike", nil)
//        onLike?(0)
    }
    
    @objc func channelPressed() {
        self.event?("onChannel", nil)
        self.hideSwipe(animated: true)
//        onChannel?(0)
    }
    
    @objc func showOthersButtonTouched() {
//        self.onOthers?()
        self.event?("onOthers", nil)
    }
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
    
    func getInfo(toHide: Bool, animated: Bool)
    {
        if toHide
        {
            if animated
            {
                UIView.animate(withDuration: 0.5, animations: {
                    self.infoBlurView.alpha = 0
                })
            }
            else
            {
                infoBlurView.alpha = 0
            }
        }
        else
        {
            // scroll text to begining
            self.infoTextView.setContentOffset(.zero, animated: false)
            UIView.animate(withDuration: 0.5, animations: {
                self.infoBlurView.alpha = 1
            })
        }
    }
}

extension FeedTableViewCell: UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
