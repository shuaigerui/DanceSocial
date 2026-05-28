//
//  DS_PersonHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

struct DS_PersonHeaderInfo {
    let coverImageName: String?
    let avatarImageName: String?
    let userName: String
    var isFollowing: Bool

    static let preview = DS_PersonHeaderInfo(
        coverImageName: "login_welcomeBg",
        avatarImageName: "login_pic",
        userName: "Marceline",
        isFollowing: false
    )
}

final class DS_PersonHeaderView: UIView {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let coverHeight: CGFloat = 200
        static let coverBottomCornerRadius: CGFloat = 24
        static let avatarSize: CGFloat = 72
        static let avatarBorderWidth: CGFloat = 2
        static let avatarOverlap: CGFloat = 36
        static let chatWidth: CGFloat = 56
        static let chatAspect: CGFloat = 168.0 / 225.0
        static let followAspect: CGFloat = 192.0 / 1029.0
        static let nameTopSpacing: CGFloat = 12
        static let followTopSpacing: CGFloat = 16
        static let commentTopSpacing: CGFloat = 20
    }

    var onChatTapped: (() -> Void)?
    var onFollowTapped: (() -> Void)?

    private var isFollowing = false

    private let coverContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.coverBottomCornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#2C2C2E")
        return imageView
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#3A3A3C")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        imageView.layer.borderWidth = Layout.avatarBorderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "person_chat"), for: .normal)
        button.addTarget(self, action: #selector(didTapChat), for: .touchUpInside)
        return button
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        return button
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "Comment"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 20)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        configure(with: .preview)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with info: DS_PersonHeaderInfo) {
        nameLabel.text = info.userName
        isFollowing = info.isFollowing
        updateFollowButton()

        if let coverImageName = info.coverImageName {
            coverImageView.image = UIImage(named: coverImageName)
        } else {
            coverImageView.image = nil
        }

        if let avatarImageName = info.avatarImageName {
            avatarImageView.image = UIImage(named: avatarImageName)
        } else {
            avatarImageView.image = nil
        }
    }

    func updateFollowState(_ following: Bool) {
        isFollowing = following
        updateFollowButton()
    }

    private func updateFollowButton() {
        let imageName = isFollowing ? "person_followed" : "person_follow"
        followButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
    }

    private func setupUI() {
        addSubview(coverContainerView)
        coverContainerView.addSubview(coverImageView)
        addSubview(avatarImageView)
        addSubview(chatButton)
        addSubview(nameLabel)
        addSubview(followButton)
        addSubview(commentLabel)

        coverContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.coverHeight)
        }

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(coverContainerView.snp.bottom).offset(-Layout.avatarOverlap)
            make.width.height.equalTo(Layout.avatarSize)
        }

        chatButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(avatarImageView)
            make.width.equalTo(Layout.chatWidth)
            make.height.equalTo(chatButton.snp.width).multipliedBy(Layout.chatAspect)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(Layout.nameTopSpacing)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
        }

        followButton.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Layout.followTopSpacing)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(followButton.snp.width).multipliedBy(Layout.followAspect)
        }

        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom).offset(Layout.commentTopSpacing)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview()
        }
    }

    @objc private func didTapChat() {
        onChatTapped?()
    }

    @objc private func didTapFollow() {
        isFollowing.toggle()
        updateFollowButton()
        onFollowTapped?()
    }
}
