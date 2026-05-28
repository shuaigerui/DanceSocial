//
//  DS_PostFeedCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_PostFeedItem {
    let postId: String?
    let userId: String?
    let avatarImageName: String?
    let userName: String
    let content: String
    /// 图片动态资源路径
    let imagePath: String?
    /// 视频动态资源路径（封面取首帧）
    let videoPath: String?
    /// 已保存的视频封面图路径（优先展示）
    let videoCoverPath: String?
}

final class DS_PostFeedCell: UITableViewCell {

    static let reuseIdentifier = "DS_PostFeedCell"

    var onAvatarTapped: (() -> Void)?
    var onCommentTapped: (() -> Void)?
    var onMoreTapped: (() -> Void)?

    private enum Layout {
        static let cardCornerRadius: CGFloat = 14
        static let cardHorizontalInset: CGFloat = 16
        static let cardVerticalSpacing: CGFloat = 12
        static let contentPadding: CGFloat = 12
        static let avatarSize: CGFloat = 40
        static let actionButtonSize: CGFloat = 32
        static let playButtonSize = CGSize(width: 44, height: 44)
        static let mediaHeight: CGFloat = 200
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#2C2C2E")
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()

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
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "post_commit"), for: .normal)
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        return button
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "post_more"), for: .normal)
        button.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        return button
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let mediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#1A1A1A")
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    private let playImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "home_play"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupAvatarTap()
    }

    private var loadingVideoPath: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        loadingVideoPath = nil
        mediaImageView.image = nil
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DS_PostFeedItem) {
        loadingVideoPath = nil
        avatarImageView.image = UserData.image(for: item.avatarImageName)
        userNameLabel.text = item.userName
        contentLabel.text = item.content

        let isVideo = item.videoPath != nil
        let hasMedia = isVideo || item.imagePath != nil

        mediaImageView.isHidden = !hasMedia
        playImageView.isHidden = !isVideo
        mediaImageView.image = nil

        if let imagePath = item.imagePath {
            mediaImageView.image = UserData.image(for: imagePath)
        } else if let coverPath = item.videoCoverPath,
                  let coverImage = UserData.image(for: coverPath) {
            mediaImageView.image = coverImage
        } else if let videoPath = item.videoPath {
            loadingVideoPath = videoPath
            DS_VideoThumbnailLoader.thumbnail(for: videoPath) { [weak self] image in
                guard let self, self.loadingVideoPath == videoPath else { return }
                self.mediaImageView.image = image
            }
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(userNameLabel)
        cardView.addSubview(commentButton)
        cardView.addSubview(moreButton)
        cardView.addSubview(contentLabel)
        cardView.addSubview(mediaImageView)
        cardView.addSubview(playImageView)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Layout.cardHorizontalInset)
            make.bottom.equalToSuperview().inset(Layout.cardVerticalSpacing)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(Layout.contentPadding)
            make.width.height.equalTo(Layout.avatarSize)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.contentPadding)
            make.centerY.equalTo(avatarImageView)
            make.width.height.equalTo(Layout.actionButtonSize)
        }

        commentButton.snp.makeConstraints { make in
            make.trailing.equalTo(moreButton.snp.leading).offset(-12)
            make.centerY.equalTo(avatarImageView)
            make.width.height.equalTo(Layout.actionButtonSize)
        }

        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(commentButton.snp.leading).offset(-8)
            make.centerY.equalTo(avatarImageView)
        }

        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.contentPadding)
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
        }

        mediaImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.contentPadding)
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.height.equalTo(Layout.mediaHeight)
            make.bottom.equalToSuperview().inset(Layout.contentPadding)
        }

        playImageView.snp.makeConstraints { make in
            make.top.equalTo(mediaImageView).offset(10)
            make.trailing.equalTo(mediaImageView).inset(10)
            make.size.equalTo(Layout.playButtonSize)
        }
    }

    private func setupAvatarTap() {
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarImageView.addGestureRecognizer(tap)
    }

    @objc private func didTapAvatar() {
        onAvatarTapped?()
    }

    @objc private func didTapMore() {
        onMoreTapped?()
    }

    @objc private func didTapComment() {
        onCommentTapped?()
    }
}
