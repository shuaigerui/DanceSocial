//
//  DS_HomeClipCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_HomeClipItem {
    let coverImageName: String?
    let avatarImageName: String?
    let title: String
}

final class DS_HomeClipCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_HomeClipCell"

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
        imageView.contentMode = .scaleAspectFit
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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = Layout.cornerRadius
    }

    func configure(with item: DS_HomeClipItem) {
        coverImageView.image = item.coverImageName.flatMap { UIImage(named: $0) }
        avatarImageView.image = item.avatarImageName.flatMap { UIImage(named: $0) }
        titleLabel.text = item.title
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
}
