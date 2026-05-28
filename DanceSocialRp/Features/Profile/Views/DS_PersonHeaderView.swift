//
//  DS_PersonHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

struct DS_PersonHeaderInfo {
    let userId: String
    let coverImageName: String?
    let avatarImageName: String?
    let userName: String
    var isFollowing: Bool

    static let preview = DS_PersonHeaderInfo(
        userId: "u_001",
        coverImageName: "login_welcomeBg",
        avatarImageName: "login_pic",
        userName: "Marceline",
        isFollowing: false
    )

    static func from(user: DS_UserModel) -> DS_PersonHeaderInfo {
        DS_PersonHeaderInfo(
            userId: user.userId,
            coverImageName: UserData.personCoverPath(for: user),
            avatarImageName: user.avatarUrl,
            userName: user.userName,
            isFollowing: user.isFollow
        )
    }
}

final class DS_PersonHeaderView: UIView {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let coverHeight: CGFloat = 470
        static let coverBottomCornerRadius: CGFloat = 24
        static let avatarSize: CGFloat = 112
        static let avatarBorderWidth: CGFloat = 2
        static let backButtonSize: CGFloat = 44
        static let backTopExtraInset: CGFloat = 8
    }

    var onBackTapped: (() -> Void)?
    var onChatTapped: (() -> Void)?

    private var targetUserId: String?
    private var isFollowing = false
    private var commentTopToFollowConstraint: Constraint?
    private var commentTopToNameConstraint: Constraint?

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#2C2C2E")
        imageView.layer.cornerRadius = 200
        imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        imageView.layer.masksToBounds = true
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

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
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
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with info: DS_PersonHeaderInfo, showsFollowAndChat: Bool = true) {
        targetUserId = info.userId
        nameLabel.text = info.userName
        isFollowing = info.isFollowing
        updateFollowButton()
        setShowsFollowAndChat(showsFollowAndChat)

        coverImageView.image = UserData.image(for: info.avatarImageName)
        avatarImageView.image = UserData.image(for: info.avatarImageName)
    }

    func setShowsFollowAndChat(_ shows: Bool) {
        chatButton.isHidden = !shows
        followButton.isHidden = !shows
        commentTopToFollowConstraint?.isActive = shows
        commentTopToNameConstraint?.isActive = !shows
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
        addSubview(coverImageView)
        addSubview(avatarImageView)
        addSubview(backButton)
        addSubview(chatButton)
        addSubview(nameLabel)
        addSubview(followButton)
        addSubview(commentLabel)

        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.coverHeight)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().offset(Self.backButtonTopOffset)
            make.width.height.equalTo(Layout.backButtonSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(coverImageView.snp.bottom).offset(-14)
            make.width.height.equalTo(Layout.avatarSize)
        }

        chatButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalTo(avatarImageView)
            make.width.equalTo(75)
            make.height.equalTo(55)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
        }

        followButton.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(64)
        }

        commentLabel.snp.makeConstraints { make in
            commentTopToFollowConstraint = make.top.equalTo(followButton.snp.bottom).offset(24).constraint
            commentTopToNameConstraint = make.top.equalTo(nameLabel.snp.bottom).offset(24).constraint
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview().offset(-16)
        }
        commentTopToNameConstraint?.deactivate()

        bringSubviewToFront(backButton)
    }

    private static var backButtonTopOffset: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        return (window?.safeAreaInsets.top ?? 47) + Layout.backTopExtraInset
    }

    @objc private func didTapBack() {
        onBackTapped?()
    }

    @objc private func didTapChat() {
        onChatTapped?()
    }

    @objc private func didTapFollow() {
        guard let userId = targetUserId, !userId.isEmpty else { return }
        isFollowing = DS_CurrentUser.shared.toggleFollow(userId: userId, isFollow: isFollowing)
        updateFollowButton()
    }
}
