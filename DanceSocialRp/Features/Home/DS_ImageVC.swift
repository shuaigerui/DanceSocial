//
//  DS_ImageVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

/// 动态图片全屏预览（布局与 DS_VideoVC 一致，仅展示静态图）
class DS_ImageVC: DS_SecondaryVC {

    private enum Layout {
        static let backButtonSize: CGFloat = 44
        static let topInset: CGFloat = 8
        static let bottomInset: CGFloat = 24
        static let horizontalInset: CGFloat = 16
        static let avatarSize: CGFloat = 40
        static let bottomGradientHeight: CGFloat = 200
    }

    private let post: DS_PostModel

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let mediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()

    private let bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
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

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    init(post: DS_PostModel) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindPost()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomGradient()
    }

    private func setupUI() {
        view.addSubview(mediaImageView)
        view.addSubview(bottomGradientView)
        view.addSubview(backButton)
        view.addSubview(avatarImageView)
        view.addSubview(userNameLabel)
        view.addSubview(contentLabel)

        mediaImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Layout.topInset)
            make.width.height.equalTo(Layout.backButtonSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(contentLabel.snp.top).offset(-8)
            make.width.height.equalTo(Layout.avatarSize)
        }

        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalTo(avatarImageView)
        }

        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.bottomInset)
        }

        bottomGradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Layout.bottomGradientHeight)
        }
    }

    private func bindPost() {
        avatarImageView.image = UserData.image(for: post.avatarUrl)
        userNameLabel.text = post.userName
        contentLabel.text = post.content
        mediaImageView.image = UserData.image(for: post.mediaUrl)
    }

    private func updateBottomGradient() {
        bottomGradientView.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.frame = bottomGradientView.bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        gradient.locations = [0, 1]
        bottomGradientView.layer.insertSublayer(gradient, at: 0)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
