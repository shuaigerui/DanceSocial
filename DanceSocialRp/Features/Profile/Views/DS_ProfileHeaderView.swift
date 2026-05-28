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
    }

    var onCoinShopTapped: (() -> Void)?
    var onReviseTapped: (() -> Void)?
    var onSetupTapped: (() -> Void)?

    private let coverContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 44
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#3A3A3C")
        imageView.layer.cornerRadius = 56
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    private lazy var coinShopButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_coin"), for: .normal)
        button.addTarget(self, action: #selector(didTapCoinShop), for: .touchUpInside)
        return button
    }()

    private lazy var reviseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_revise"), for: .normal)
        button.addTarget(self, action: #selector(didTapRevise), for: .touchUpInside)
        return button
    }()

    private lazy var setupButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_setup"), for: .normal)
        button.addTarget(self, action: #selector(didTapSetup), for: .touchUpInside)
        return button
    }()

    private let releaseLabel: UILabel = {
        let label = UILabel()
        label.text = "release"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 20)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        configure(with: DS_ProfileHeaderInfo.preview)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with user: DS_UserModel) {
        nameLabel.text = user.userName
        let avatar = DS_CurrentUser.shared.avatarImage(for: user) ?? UserData.image(for: user.avatarUrl)
        coverImageView.image = avatar
        avatarImageView.image = avatar
    }

    func configure(with info: DS_ProfileHeaderInfo) {
        nameLabel.text = info.userName
        let avatar = UserData.image(for: info.avatarImageName ?? info.coverImageName)
        coverImageView.image = avatar
        avatarImageView.image = avatar
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
            make.height.equalTo(350)
        }

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(coverContainerView.snp.bottom).offset(-56)
            make.width.height.equalTo(112)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(9)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(coverContainerView.snp.bottom)
        }

        coinShopButton.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(80)
        }

        reviseButton.snp.makeConstraints { make in
            make.top.equalTo(coinShopButton.snp.bottom).offset(14)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.trailing.equalTo(setupButton.snp.leading).offset(-7)
            make.height.equalTo(80)
        }

        setupButton.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(reviseButton)
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        releaseLabel.snp.makeConstraints { make in
            make.top.equalTo(reviseButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
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
