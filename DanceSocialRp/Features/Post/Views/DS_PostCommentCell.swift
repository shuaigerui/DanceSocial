//
//  DS_PostCommentCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_PostCommentItem {
    let avatarImageName: String?
    let userName: String
    let text: String
}

final class DS_PostCommentCell: UITableViewCell {

    static let reuseIdentifier = "DS_PostCommentCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let avatarSize: CGFloat = 36
        static let actionButtonSize: CGFloat = 28
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "post_more"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.85)
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

    func configure(with item: DS_PostCommentItem) {
        avatarImageView.image = item.avatarImageName.flatMap { UIImage(named: $0) }
        userNameLabel.text = item.userName
        commentLabel.text = item.text
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(commentLabel)

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().inset(10)
            make.width.height.equalTo(Layout.avatarSize)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(avatarImageView)
            make.width.height.equalTo(Layout.actionButtonSize)
        }

        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
            make.centerY.equalTo(avatarImageView)
        }

        commentLabel.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel)
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}
