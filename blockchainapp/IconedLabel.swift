import UIKit

enum IconLabelType: String {
	case
	playingIndicator = "playingIcon",
	time = "timeCount",
	comments = "commentCount",
	likes = "likesCount",
	listens = "listensCount",
	subs = "followersCount",
	tracks = "tracksCount"
}

class IconedLabel: UIView {
	var type: IconLabelType = .likes
	private var textLabel: UILabel = {
		let label = UILabel()
		label.textColor = AppColor.Title.gray
		label.font = AppFont.Text.mid
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
		
		if type == .playingIndicator {
			self.textLabel.textColor = UIColor.init(red: 1, green: 102.0/255, blue: 102.0/255, alpha: 1)
			self.textLabel.text = "playing now"
		}
	}
	
	func set(isTemplate: Bool) {
		if isTemplate {
			self.iconImageView.image = nil
			self.textLabel.text = "    "
			self.textLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
			self.textLabel.layer.cornerRadius = 4
			self.iconImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
			self.iconImageView.layer.cornerRadius = 4
		} else {
			self.iconImageView.image = UIImage.init(named: type.rawValue)
			self.iconImageView.backgroundColor = .clear
			self.iconImageView.layer.cornerRadius = 0
			self.textLabel.backgroundColor = .clear
			self.textLabel.layer.cornerRadius = 0
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
