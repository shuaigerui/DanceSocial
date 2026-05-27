//
//  DS_AIChatMessageCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

enum DS_AIChatSender {
    case ai
    case user
}

struct DS_AIChatMessage {
    let sender: DS_AIChatSender
    let text: String
}

final class DS_AIChatMessageCell: UITableViewCell {

    static let reuseIdentifier = "DS_AIChatMessageCell"

    private enum Layout {
        static let avatarSize: CGFloat = 36
        static let bubbleCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let bubbleMaxWidthRatio: CGFloat = 0.72
    }

    private let aiContainerView = UIView()
    private let userContainerView = UIView()

    private let aiAvatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AI_avatar"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let userAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#D8D8D8")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let aiBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let userBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#B19DFF")
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let aiMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let userMessageLabel: UILabel = {
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

    func configure(with message: DS_AIChatMessage) {
        let isAI = message.sender == .ai
        aiContainerView.isHidden = !isAI
        userContainerView.isHidden = isAI

        if isAI {
            aiMessageLabel.text = message.text
        } else {
            userMessageLabel.text = message.text
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(aiContainerView)
        contentView.addSubview(userContainerView)

        aiContainerView.addSubview(aiAvatarImageView)
        aiContainerView.addSubview(aiBubbleView)
        aiBubbleView.addSubview(aiMessageLabel)

        userContainerView.addSubview(userAvatarImageView)
        userContainerView.addSubview(userBubbleView)
        userBubbleView.addSubview(userMessageLabel)

        aiContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        userContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        aiAvatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().inset(8)
            make.width.height.equalTo(Layout.avatarSize)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }

        aiBubbleView.snp.makeConstraints { make in
            make.leading.equalTo(aiAvatarImageView.snp.trailing).offset(10)
            make.top.equalTo(aiAvatarImageView)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(Layout.bubbleMaxWidthRatio)
            make.bottom.equalToSuperview().inset(8)
        }

        aiMessageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }

        userAvatarImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().inset(8)
            make.width.height.equalTo(Layout.avatarSize)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }

        userBubbleView.snp.makeConstraints { make in
            make.trailing.equalTo(userAvatarImageView.snp.leading).offset(-10)
            make.top.equalTo(userAvatarImageView)
            make.leading.greaterThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(Layout.bubbleMaxWidthRatio)
            make.bottom.equalToSuperview().inset(8)
        }

        userMessageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }
    }
}
