import UIKit
import SnapKit

class ChannelTrackCell: UITableViewCell {
	
	static let cellID: String = "ChannelTrackCellID"
	
	let trackImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.cornerRadius = 6
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
		return imageView
	}()
	let trackNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.textColor = .black
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 2
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
	
	var dataLabels: [IconLabelType: IconedLabel] = [:]
	
	weak var track: Track? = nil {
		didSet {
			if let iconUrl = track?.image.buildImageURL() {
				trackImageView.sd_setImage(with: iconUrl)
			} else {
				trackImageView.image = nil
			}
			
			trackNameLabel.attributedText = type(of: self).trackText(text: track?.name ?? "")

			self.timeLabel.text = (track?.publishedAt ?? Date()).formatString()
			
			dataLabels[.listens]?.setData(data: Int64(track?.listenCount ?? 0))
			dataLabels[.time]?.setData(data: Int64(track?.length ?? 0))
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(trackImageView)
		trackImageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
			make.width.equalTo(60)
			make.height.equalTo(60)
		}
		
		self.contentView.addSubview(trackNameLabel)
		trackNameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(trackImageView.snp.right).inset(-14)
			make.top.equalToSuperview().inset(12)
//			make.right.equalToSuperview().inset(16)
		}
		
		self.contentView.addSubview(timeLabel)
		timeLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(16)
			make.top.equalTo(trackNameLabel).inset(4)
			make.left.equalTo(trackNameLabel.snp.right).inset(-4)
			make.width.equalTo(60)
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
		
		let view = UIView()
		view.backgroundColor = AppColor.Element.tomato.withAlphaComponent(0.2)
		self.contentView.addSubview(view)
		view.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(90)
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(1)
		}
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
			.boundingRect(with: CGSize.init(width: width - 16 - 60 - 16 - 60, height: 9999),
						  options: .usesLineFragmentOrigin,
						  context: nil)
		return round(min(rect.height, 44)) + 12 + 42 - 7
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}

