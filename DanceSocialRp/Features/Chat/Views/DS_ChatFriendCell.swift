//
//  DS_ChatFriendCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_ChatFriendItem {
    let avatarImageName: String?
    let name: String
}

final class DS_ChatFriendCell: UITableViewCell {

    static let reuseIdentifier = "DS_ChatFriendCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let rowHeight: CGFloat = 64
        static let avatarSize: CGFloat = 44
        static let spacing: CGFloat = 8
        static let cardCornerRadius: CGFloat = 24
    }

    var onChatTapped: (() -> Void)?

    private let infoCardView: UIView = {
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

    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "friend_chat"), for: .normal)
        button.addTarget(self, action: #selector(didTapChat), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DS_ChatFriendItem) {
        avatarImageView.image = item.avatarImageName.flatMap { UIImage(named: $0) }
        nameLabel.text = item.name
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(infoCardView)
        contentView.addSubview(chatButton)
        infoCardView.addSubview(avatarImageView)
        infoCardView.addSubview(nameLabel)

        infoCardView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview()
            make.height.equalTo(Layout.rowHeight)
            make.trailing.equalTo(chatButton.snp.leading).offset(-Layout.spacing)
            make.bottom.equalToSuperview().offset(-12)
        }

        chatButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(infoCardView)
            make.height.equalTo(Layout.rowHeight)
            make.width.equalTo(140)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.avatarSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func didTapChat() {
        onChatTapped?()
    }
}
