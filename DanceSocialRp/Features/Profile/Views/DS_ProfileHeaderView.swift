//
//  DS_ProfileHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_ProfileHeaderInfo {
    let coverImageName: String?
    let avatarImageName: String?
    let userName: String

    static let preview = DS_ProfileHeaderInfo(
        coverImageName: "login_welcomeBg",
        avatarImageName: "login_pic",
        userName: "Marceline"
    )
}

final class DS_ProfileHeaderView: UIView {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let coverHeight: CGFloat = 200
        static let coverBottomCornerRadius: CGFloat = 24
        static let avatarSize: CGFloat = 72
        static let avatarBorderWidth: CGFloat = 3
        static let avatarOverlap: CGFloat = 36
        static let profileTopSpacing: CGFloat = 12
        static let buttonSpacing: CGFloat = 12
        static let coinAspect: CGFloat = 240.0 / 1029.0
        static let actionAspect: CGFloat = 240.0 / 504.0
        static let releaseTopSpacing: CGFloat = 20
    }

    var onCoinShopTapped: (() -> Void)?
    var onReviseTapped: (() -> Void)?
    var onSetupTapped: (() -> Void)?

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

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private lazy var coinShopButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_coin"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapCoinShop), for: .touchUpInside)
        return button
    }()

    private lazy var reviseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_revise"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapRevise), for: .touchUpInside)
        return button
    }()

    private lazy var setupButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_setup"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapSetup), for: .touchUpInside)
        return button
    }()

    private let releaseLabel: UILabel = {
        let label = UILabel()
        label.text = "release"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 18)
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

    func configure(with info: DS_ProfileHeaderInfo) {
        nameLabel.text = info.userName

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

    private func setupUI() {
        addSubview(coverContainerView)
        coverContainerView.addSubview(coverImageView)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(coinShopButton)
        addSubview(reviseButton)
        addSubview(setupButton)
        addSubview(releaseLabel)

        coverContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.coverHeight)
        }

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(coverContainerView.snp.bottom).offset(-Layout.avatarOverlap)
            make.width.height.equalTo(Layout.avatarSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(14)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(avatarImageView)
        }

        coinShopButton.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(Layout.profileTopSpacing)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(coinShopButton.snp.width).multipliedBy(Layout.coinAspect)
        }

        reviseButton.snp.makeConstraints { make in
            make.top.equalTo(coinShopButton.snp.bottom).offset(Layout.buttonSpacing)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.trailing.equalTo(setupButton.snp.leading).offset(-Layout.buttonSpacing)
            make.height.equalTo(reviseButton.snp.width).multipliedBy(Layout.actionAspect)
            make.width.equalTo(setupButton)
        }

        setupButton.snp.makeConstraints { make in
            make.top.equalTo(reviseButton)
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(setupButton.snp.width).multipliedBy(Layout.actionAspect)
        }

        releaseLabel.snp.makeConstraints { make in
            make.top.equalTo(reviseButton.snp.bottom).offset(Layout.releaseTopSpacing)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview()
        }
    }

    @objc private func didTapCoinShop() {
        onCoinShopTapped?()
    }

    @objc private func didTapRevise() {
        onReviseTapped?()
    }

    @objc private func didTapSetup() {
        onSetupTapped?()
    }
}
