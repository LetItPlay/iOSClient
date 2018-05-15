import UIKit
import SnapKit
import SDWebImage

class SmallTrackTableViewCell: UITableViewCell, StandartTableViewCell {
    var event: ((String, [String : Any]?) -> Void)?

	static let cellID: String = "LikeTrackCellID"
    var separator = UIView()
    
    public var onOthers: (() -> Void)?
	
	let trackImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 6
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "trackPlaceholder")
		return imageView
	}()
	let trackNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.textColor = .black
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		return label
	}()
	let channelNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor.black.withAlphaComponent(0.6)
		return label
	}()
	let timeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor.black.withAlphaComponent(0.6)
		label.textAlignment = .right
		return label
	}()
	
	let reserveTimeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor.black.withAlphaComponent(0.6)
		label.textAlignment = .right
		return label
	}()
    
    var showOthersButton = ShowOthersButton()
	
    var dataLabels: [IconLabelType: IconedLabel] = [:]
    
    static func height(data: Any, width: CGFloat) -> CGFloat {
        return 107
    }
    
    func fill(data: Any?) {
        guard let viewModel = data as? TrackViewModel  else {
            return
        }
        self.fill(vm: viewModel)
    }
	
	func fill(vm: TrackViewModel) {
        
        DispatchQueue.main.async {
            let viewModel = SmallTrackViewModel.init(track: vm)
            
            if let iconUrl = viewModel.iconUrl {
                self.trackImageView.sd_setImage(with: iconUrl, placeholderImage: UIImage(named: "trackPlaceholder"), options: SDWebImageOptions.refreshCached, completed: nil)
            } else {
                self.trackImageView.image = UIImage(named: "trackPlaceholder")
            }
            
            self.trackNameLabel.attributedText = Common.trackText(text: viewModel.trackName)
            self.channelNameLabel.text = viewModel.channelName
            
            self.timeLabel.text = viewModel.time
            
            self.dataLabels[.listens]?.set(text: viewModel.listens)
            self.dataLabels[.time]?.set(text: viewModel.length)
            
            self.dataLabels[.listens]?.isHidden = vm.isPlaying
            self.dataLabels[.playingIndicator]?.isHidden = !vm.isPlaying
        }
    }
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(trackImageView)
		trackImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.top.equalToSuperview().inset(12)
			make.width.equalTo(60)
			make.height.equalTo(60)
		}
		
		self.contentView.addSubview(channelNameLabel)
		channelNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(trackImageView.snp.right).inset(-14)
			make.top.equalTo(trackImageView)
			make.height.equalTo(18)
		}
		
		self.contentView.addSubview(timeLabel)
		timeLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(16)
			make.centerY.equalTo(channelNameLabel)
			make.left.equalTo(channelNameLabel.snp.right).inset(-10)
			make.width.equalTo(60)
		}
		
		self.contentView.addSubview(trackNameLabel)
		trackNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(channelNameLabel)
			make.top.equalTo(channelNameLabel.snp.bottom).inset(2)
			make.right.equalToSuperview().inset(16)
		}
		
		let timeCount = IconedLabel(type: .time)
		let listensCount = IconedLabel(type: .listens)
		let playingIndicator = IconedLabel(type: .playingIndicator)
		
		self.contentView.addSubview(timeCount)
		timeCount.snp.makeConstraints { (make) in
			make.top.equalTo(trackNameLabel.snp.bottom).inset(-6)
			make.left.equalTo(trackNameLabel)
		}
		
		self.contentView.addSubview(listensCount)
		listensCount.snp.makeConstraints { (make) in
			make.left.equalTo(timeCount.snp.right).inset(-10)
			make.centerY.equalTo(timeCount)
		}
		
		self.contentView.addSubview(playingIndicator)
		playingIndicator.snp.makeConstraints { (make) in
			make.left.equalTo(timeCount.snp.right).inset(-10)
			make.centerY.equalTo(timeCount)
		}
		
		playingIndicator.isHidden = true
        
        self.showOthersButton.addTarget(self, action: #selector(showOthersButtonTouched), for: .touchUpInside)
        self.contentView.addSubview(showOthersButton)
        showOthersButton.snp.makeConstraints { (make) in
            make.height.equalTo(26)
            make.width.equalTo(26)
            make.right.equalTo(-8)
            make.bottom.equalTo(-8)
        }
		
        self.dataLabels = [.time: timeCount, .listens: listensCount, .playingIndicator: playingIndicator]
		
		self.separatorInset.left = 90
		self.selectionStyle = .none
		
		let view = UIView()
		view.backgroundColor = AppColor.Element.tomato.withAlphaComponent(0.2)
		self.contentView.addSubview(view)
		view.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(90)
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(1)
		}
		self.separator = view
	}
    
    @objc func showOthersButtonTouched() {
        self.event!("onOthers", nil)
//        self.onOthers?()
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
