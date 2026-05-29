//
//  DS_LiveRoomCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

enum DS_LiveRoomListType {
    case recommend
    case creation
}

struct DS_LiveRoomItem {
    let coverImageName: String?
    let avatarImageNames: [String?]
    let title: String
}

final class DS_LiveRoomCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_LiveRoomCell"

    private enum Layout {
        static let cornerRadius: CGFloat = 10
        static let avatarSize: CGFloat = 24
        static let avatarOverlap: CGFloat = 8
        static let goButtonSize = CGSize(width: 36, height: 36)
        static let contentInset: CGFloat = 10
    }

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#1A1A1A")
        return imageView
    }()

    var onActionTapped: (() -> Void)?

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        return button
    }()

    private let avatarImageViews: [UIImageView] = (0..<3).map { _ in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
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
        avatarImageViews.forEach {
            $0.layer.cornerRadius = Layout.avatarSize / 2
        }
    }

    func configure(with item: DS_LiveRoomItem, listType: DS_LiveRoomListType) {
        coverImageView.image = UserData.image(for: item.coverImageName)
        titleLabel.text = item.title

        switch listType {
        case .recommend:
            actionButton.setImage(UIImage(named: "live_go"), for: .normal)
            actionButton.isUserInteractionEnabled = false
        case .creation:
            actionButton.setImage(UIImage(named: "live_del"), for: .normal)
            actionButton.isUserInteractionEnabled = true
        }

        for (index, imageView) in avatarImageViews.enumerated() {
            let path = item.avatarImageNames.indices.contains(index) ? item.avatarImageNames[index] : nil
            imageView.image = UserData.image(for: path)
        }
    }

    private func setupUI() {
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.hex("#2C2C2E")

        contentView.addSubview(coverImageView)
        contentView.addSubview(actionButton)
        avatarImageViews.forEach { contentView.addSubview($0) }
        contentView.addSubview(titleLabel)

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        actionButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Layout.contentInset)
            make.size.equalTo(Layout.goButtonSize)
        }

        avatarImageViews.enumerated().forEach { index, imageView in
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(Layout.contentInset)
                make.width.height.equalTo(Layout.avatarSize)
                if index == 0 {
                    make.leading.equalToSuperview().inset(Layout.contentInset)
                } else {
                    make.leading.equalTo(avatarImageViews[index - 1].snp.leading).offset(Layout.avatarSize - Layout.avatarOverlap)
                }
            }
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.contentInset)
            make.bottom.equalToSuperview().inset(Layout.contentInset)
        }
    }

    @objc private func didTapAction() {
        onActionTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onActionTapped = nil
    }
}
