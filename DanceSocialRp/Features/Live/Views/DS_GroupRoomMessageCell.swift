//
//  DS_GroupRoomMessageCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

struct DS_GroupRoomMessage {
    let userName: String?
    let avatarPath: String?
    let text: String
    let isSystem: Bool

    static func system(_ text: String) -> DS_GroupRoomMessage {
        DS_GroupRoomMessage(userName: nil, avatarPath: nil, text: text, isSystem: true)
    }

    static func member(userName: String, avatarPath: String?, text: String) -> DS_GroupRoomMessage {
        DS_GroupRoomMessage(userName: userName, avatarPath: avatarPath, text: text, isSystem: false)
    }
}

final class DS_GroupRoomMessageCell: UITableViewCell {

    static let reuseIdentifier = "DS_GroupRoomMessageCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let avatarSize: CGFloat = 36
        static let systemCornerRadius: CGFloat = 12
    }

    private let systemContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#2C2C2E")
        view.layer.cornerRadius = Layout.systemCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let systemLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hex("#CCCCCC")
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let memberContainerView = UIView()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hex("#E5E5E5")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: DS_GroupRoomMessage) {
        systemContainerView.isHidden = !message.isSystem
        memberContainerView.isHidden = message.isSystem

        if message.isSystem {
            systemLabel.text = message.text
            return
        }

        nameLabel.text = message.userName
        messageLabel.text = message.text
        avatarImageView.image = UserData.image(for: message.avatarPath)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(systemContainerView)
        contentView.addSubview(memberContainerView)
        systemContainerView.addSubview(systemLabel)
        memberContainerView.addSubview(avatarImageView)
        memberContainerView.addSubview(nameLabel)
        memberContainerView.addSubview(messageLabel)

        systemContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview().inset(8)
        }

        systemLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }

        memberContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().inset(10)
            make.width.height.equalTo(Layout.avatarSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(avatarImageView)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}
