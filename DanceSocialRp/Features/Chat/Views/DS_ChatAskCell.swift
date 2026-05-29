//
//  DS_ChatAskCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_ChatAskItem {
    let userId: String
    let avatarImageName: String?
    let name: String
    var isFollowing: Bool
}

final class DS_ChatAskCell: UITableViewCell {

    static let reuseIdentifier = "DS_ChatAskCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let rowHeight: CGFloat = 64
        static let avatarSize: CGFloat = 44
        static let spacing: CGFloat = 8
        static let cardCornerRadius: CGFloat = 24
    }

    var onFollowTapped: (() -> Void)?

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

    private lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
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

    func configure(with item: DS_ChatAskItem) {
        avatarImageView.image = UserData.image(for: item.avatarImageName)
        nameLabel.text = item.name
        updateFollowButton(isFollowing: item.isFollowing)
    }

    private func updateFollowButton(isFollowing: Bool) {
        let imageName = isFollowing ? "ask_follow_off" : "ask_follow"
        followButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(infoCardView)
        contentView.addSubview(followButton)
        infoCardView.addSubview(avatarImageView)
        infoCardView.addSubview(nameLabel)

        infoCardView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview()
            make.height.equalTo(Layout.rowHeight)
            make.trailing.equalTo(followButton.snp.leading).offset(-Layout.spacing)
            make.bottom.equalToSuperview().offset(-12)
        }

        followButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(infoCardView)
            make.width.equalTo(140)
            make.height.equalTo(Layout.rowHeight)
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

    @objc private func didTapFollow() {
        onFollowTapped?()
    }
}
