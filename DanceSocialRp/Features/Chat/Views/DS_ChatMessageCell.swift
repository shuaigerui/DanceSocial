//
//  DS_ChatMessageCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_ChatMessageItem {
    let avatarImageName: String?
    let name: String
    let date: String
    let message: String
    let hasUnread: Bool
}

final class DS_ChatMessageCell: UITableViewCell {

    static let reuseIdentifier = "DS_ChatMessageCell"

    private enum Layout {
        static let cardCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let cardHeight: CGFloat = 64
        static let avatarSize: CGFloat = 48
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#E8E8E8")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hex("#999999")
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hex("#333333")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()

    private let unreadDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#FF3B30")
        view.layer.cornerRadius = 4
        view.isHidden = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DS_ChatMessageItem) {
        avatarImageView.image = item.avatarImageName.flatMap { UIImage(named: $0) }
        nameLabel.text = item.name
        dateLabel.text = item.date
        messageLabel.text = item.message
        unreadDotView.isHidden = !item.hasUnread
    }

    private func setupUI() {
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(unreadDotView)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.cardHeight)
            make.bottom.equalToSuperview().offset(-12)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.avatarSize)
        }

        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(14)
            make.width.lessThanOrEqualTo(120)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-8)
            make.centerY.equalTo(dateLabel)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(unreadDotView.snp.leading).offset(-8)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
        }

        unreadDotView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(14)
            make.width.height.equalTo(8)
        }
    }
}
