
import UIKit
import SnapKit

class NewFeedTableViewCell: UITableViewCell {

	private let iconImageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 10
		imageView.snp.makeConstraints({ (maker) in
			maker.width.equalTo(20)
			maker.height.equalTo(20)
		})
		return imageView
	}()
	
	private let channelLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
		label.textColor = UIColor.init(white: 2/255.0, alpha: 1)
		label.textAlignment = .left
		return label
	}()

	private let timeAgoLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
		label.textColor = UIColor.init(white: 74/255.0, alpha: 1)
		label.textAlignment = .right
		label.snp.makeConstraints { maker in
			maker.width.lessThanOrEqualTo(60)
		 }
		return label
	}()

	private let mainPictureImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()


	
	public static let height: CGFloat = 343.0
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.selectionStyle = .none

		self.contentView.layer.masksToBounds = true
		self.contentView.layer.cornerRadius = 9.0
		
		
	}

	func viewInitialize() {

	}

	required init?(coder aDecoder: NSCoder) {
		return nil
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
