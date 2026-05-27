//
//  DS_ChatRoomMessageCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

enum DS_ChatRoomMessageSender {
    case peer
    case me
}

struct DS_ChatRoomMessage {
    let sender: DS_ChatRoomMessageSender
    let text: String
}

final class DS_ChatRoomMessageCell: UITableViewCell {

    static let reuseIdentifier = "DS_ChatRoomMessageCell"

    private enum Layout {
        static let avatarSize: CGFloat = 36
        static let bubbleCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let bubbleMaxWidthRatio: CGFloat = 0.72
    }

    private let peerContainerView = UIView()
    private let meContainerView = UIView()

    private let peerAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#3A3A3C")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let meAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#3A3A3C")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let peerBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#B19DFF")
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let meBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#9D4EDD")
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let peerMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let meMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
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

    func configure(
        with message: DS_ChatRoomMessage,
        peerAvatarImageName: String?,
        meAvatarImageName: String?
    ) {
        let isPeer = message.sender == .peer
        peerContainerView.isHidden = !isPeer
        meContainerView.isHidden = isPeer

        if let peerAvatarImageName, let image = UIImage(named: peerAvatarImageName) {
            peerAvatarImageView.image = image
        }
        if let meAvatarImageName, let image = UIImage(named: meAvatarImageName) {
            meAvatarImageView.image = image
        }

        if isPeer {
            peerMessageLabel.text = message.text
        } else {
            meMessageLabel.text = message.text
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(peerContainerView)
        contentView.addSubview(meContainerView)

        peerContainerView.addSubview(peerAvatarImageView)
        peerContainerView.addSubview(peerBubbleView)
        peerBubbleView.addSubview(peerMessageLabel)

        meContainerView.addSubview(meAvatarImageView)
        meContainerView.addSubview(meBubbleView)
        meBubbleView.addSubview(meMessageLabel)

        peerContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        meContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        peerAvatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().inset(8)
            make.width.height.equalTo(Layout.avatarSize)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }

        peerBubbleView.snp.makeConstraints { make in
            make.leading.equalTo(peerAvatarImageView.snp.trailing).offset(10)
            make.top.equalTo(peerAvatarImageView)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(Layout.bubbleMaxWidthRatio)
            make.bottom.equalToSuperview().inset(8)
        }

        peerMessageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }

        meAvatarImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().inset(8)
            make.width.height.equalTo(Layout.avatarSize)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }

        meBubbleView.snp.makeConstraints { make in
            make.trailing.equalTo(meAvatarImageView.snp.leading).offset(-10)
            make.top.equalTo(meAvatarImageView)
            make.leading.greaterThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(Layout.bubbleMaxWidthRatio)
            make.bottom.equalToSuperview().inset(8)
        }

        meMessageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }
    }
}
