//
//  DS_HomeTeamCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_HomeTeamItem {
    let hostUserId: String?
    let coverImageName: String?
    let avatarImageName: String?
    let title: String
}

final class DS_HomeTeamCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_HomeTeamCell"

    var onAvatarTapped: (() -> Void)?

    private enum Layout {
        static let cornerRadius: CGFloat = 10
        static let footerHeight: CGFloat = 38
        static let avatarSize: CGFloat = 36
        static let avatarBorderWidth: CGFloat = 2
    }

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#1A1A1A")
        return imageView
    }()

    private let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#2C2C2C")
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = Layout.avatarBorderWidth
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
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

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = Layout.cornerRadius
        avatarImageView.layer.cornerRadius = Layout.avatarSize / 2
    }

    func configure(with item: DS_HomeTeamItem) {
        coverImageView.image = UserData.image(for: item.coverImageName)
        avatarImageView.image = UserData.image(for: item.avatarImageName)
        titleLabel.text = item.title
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.hex("#2C2C2C")
        contentView.clipsToBounds = true

        contentView.addSubview(coverImageView)
        contentView.addSubview(footerView)
        contentView.addSubview(avatarImageView)
        footerView.addSubview(titleLabel)

        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }

        footerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Layout.footerHeight)
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(footerView.snp.top)
            make.width.height.equalTo(Layout.avatarSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(8)
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
