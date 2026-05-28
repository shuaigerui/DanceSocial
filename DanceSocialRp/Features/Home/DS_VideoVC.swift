//
//  DS_VideoVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import AVFoundation
import UIKit

class DS_VideoVC: DS_SecondaryVC {

    private enum Layout {
        static let backButtonSize: CGFloat = 44
        static let topInset: CGFloat = 8
        static let pauseButtonSize = CGSize(width: 72, height: 72)
        static let bottomInset: CGFloat = 24
        static let horizontalInset: CGFloat = 16
        static let avatarSize: CGFloat = 40
        static let bottomGradientHeight: CGFloat = 200
    }

    private let post: DS_PostModel
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var endObserver: NSObjectProtocol?
    private var isPlaying = false

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_pause"), for: .normal)
        button.addTarget(self, action: #selector(didTapTogglePlayback), for: .touchUpInside)
        button.isHidden = true
        return button
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
        setupPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
        updateBottomGradient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseVideo()
        if isMovingFromParent {
            tearDownPlayer()
        }
    }

    private func tearDownPlayer() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    private func setupUI() {
        view.addSubview(bottomGradientView)
        view.addSubview(backButton)
        view.addSubview(pauseButton)
        view.addSubview(avatarImageView)
        view.addSubview(userNameLabel)
        view.addSubview(contentLabel)

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Layout.topInset)
            make.width.height.equalTo(Layout.backButtonSize)
        }

        pauseButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.pauseButtonSize)
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTogglePlayback))
        view.addGestureRecognizer(tap)
    }

    private func bindPost() {
        avatarImageView.image = UserData.image(for: post.avatarUrl)
        userNameLabel.text = post.userName
        contentLabel.text = post.content
    }

    private func setupPlayer() {
        guard let path = post.mediaUrl,
              let url = UserData.mediaFileURL(path: path) else {
            return
        }

        let player = AVPlayer(url: url)
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        playerLayer = layer

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.playVideo()
        }
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

    private func playVideo() {
        player?.play()
        isPlaying = true
        pauseButton.isHidden = true
    }

    private func pauseVideo() {
        player?.pause()
        isPlaying = false
        pauseButton.isHidden = false
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapTogglePlayback() {
        if isPlaying {
            pauseVideo()
        } else {
            playVideo()
        }
    }
}
