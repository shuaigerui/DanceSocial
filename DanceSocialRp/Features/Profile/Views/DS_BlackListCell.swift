//
//  DS_BlackListCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

struct DS_BlackListItem {
    let avatarImageName: String?
    let userName: String
}

final class DS_BlackListCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_BlackListCell"

    private enum Layout {
        static let cardCornerRadius: CGFloat = 24
        static let avatarSize: CGFloat = 66
    }

    var onCancelTapped: (() -> Void)?

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.cardCornerRadius
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
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "black_cancel"), for: .normal)
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DS_BlackListItem) {
        avatarImageView.image = item.avatarImageName.flatMap { UIImage(named: $0) }
        nameLabel.text = item.userName
    }

    private func setupUI() {
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(cancelButton)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(65)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Layout.avatarSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }

    @objc private func didTapCancel() {
        onCancelTapped?()
    }
}
