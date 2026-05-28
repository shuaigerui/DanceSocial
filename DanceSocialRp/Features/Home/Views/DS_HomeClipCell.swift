//
//  DS_HomeClipCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_HomeClipItem {
    let userId: String?
    /// 视频资源路径，封面取首帧
    let videoPath: String?
    /// 静态封面路径（优先于首帧生成）
    let videoCoverPath: String?
    let avatarImageName: String?
    let title: String
}

final class DS_HomeClipCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_HomeClipCell"

    var onAvatarTapped: (() -> Void)?

    private enum Layout {
        static let cornerRadius: CGFloat = 10
        static let avatarSize: CGFloat = 28
        static let playButtonSize = CGSize(width: 40, height: 40)
        static let bottomInset: CGFloat = 10
        static let horizontalInset: CGFloat = 10
    }

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#1A1A1A")
        return imageView
    }()

    private let playImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "home_play"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        imageView.layer.cornerRadius = Layout.avatarSize / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAvatarTap()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var loadingVideoPath: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        loadingVideoPath = nil
        coverImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = Layout.cornerRadius
    }

    func configure(with item: DS_HomeClipItem) {
        loadingVideoPath = item.videoPath
        coverImageView.image = nil
        avatarImageView.image = UserData.image(for: item.avatarImageName)
        titleLabel.text = item.title
        playImageView.isHidden = item.videoPath == nil

        if let coverPath = item.videoCoverPath,
           let coverImage = UserData.image(for: coverPath) {
            coverImageView.image = coverImage
            return
        }

        guard let videoPath = item.videoPath else { return }

        DS_VideoThumbnailLoader.thumbnail(for: videoPath) { [weak self] image in
            guard let self, self.loadingVideoPath == videoPath else { return }
            self.coverImageView.image = image
        }
    }

    private func setupUI() {
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.hex("#2C2C2E")

        contentView.addSubview(coverImageView)
        contentView.addSubview(playImageView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        playImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.size.equalTo(Layout.playButtonSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(Layout.bottomInset)
            make.width.height.equalTo(Layout.avatarSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(avatarImageView)
        }
    }

    private func setupAvatarTap() {
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap))
        avatarImageView.addGestureRecognizer(tap)
    }

    @objc private func handleAvatarTap() {
        onAvatarTapped?()
    }
}
