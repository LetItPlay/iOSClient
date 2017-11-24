import UIKit
import SnapKit

class SmallTrackTableViewCell: UITableViewCell {

	static let cellID: String = "LikeTrackCellID"
	
	let trackImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 6
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	let trackNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.textColor = .black
		label.numberOfLines = 2
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
	
	var dataLabels: [IconLabelType: IconedLabel] = [:]
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(trackImageView)
		trackImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
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
			make.top.equalTo(channelNameLabel.snp.bottom).inset(-1)
			make.right.equalToSuperview().inset(16)
		}
		
		let timeCount = IconedLabel(type: .time)
		let listensCount = IconedLabel(type: .listens)
		let playingIndicator = IconedLabel(type: .playingIndicator)
		
		self.contentView.addSubview(timeCount)
		timeCount.snp.makeConstraints { (make) in
			make.top.equalTo(trackNameLabel.snp.bottom).inset(-6)
			make.left.equalTo(trackNameLabel)
			make.bottom.equalToSuperview().inset(12)
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
		
		self.dataLabels = [.time: timeCount, .listens: listensCount, .playingIndicator: playingIndicator]
		
		self.separatorInset.left = 90
		self.selectionStyle = .none
		
		trackImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		trackNameLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		channelNameLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		timeLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
		
		trackNameLabel.layer.masksToBounds = true
		channelNameLabel.layer.masksToBounds = true
		timeLabel.layer.masksToBounds = true
		
		trackNameLabel.layer.cornerRadius = 4
		channelNameLabel.layer.cornerRadius = 4
		timeLabel.layer.cornerRadius = 4

		trackNameLabel.text = " "
		channelNameLabel.text = " "
		timeLabel.text = " "
		
		timeCount.set(isTemplate: true)
		listensCount.set(isTemplate: true)
	}
	
	static func trackText(text: String) -> NSAttributedString {
		let para = NSMutableParagraphStyle()
		para.lineBreakMode = .byWordWrapping
		para.minimumLineHeight = 22
		para.maximumLineHeight = 22
		return NSAttributedString.init(string: text, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .paragraphStyle: para])
	}
	
	static func height(text: String, width: CGFloat) -> CGFloat {
		let rect = self.trackText(text: text)
			.boundingRect(with: CGSize.init(width: width, height: 9999),
						  options: .usesLineFragmentOrigin,
						  context: nil)
		return min(rect.height, 44) + 31 + 32
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
