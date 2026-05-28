//
//  DS_LiveHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_LiveHeaderView: UIView {

    var onTabSelected: ((DS_LiveRoomListType) -> Void)?
    var onCreateTapped: (() -> Void)?

    private(set) var selectedTab: DS_LiveRoomListType = .recommend

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        updateTabSelection(.recommend)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTabSelection(_ tab: DS_LiveRoomListType) {
        selectedTab = tab
        recommendButton.isSelected = tab == .recommend
        creationButton.isSelected = tab == .creation
    }

    private func setupUI() {
        addSubview(titleView)
        addSubview(topView)
        addSubview(releaseButton)
        addSubview(recommendButton)
        addSubview(creationButton)

        titleView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.width.equalTo(180)
            make.height.equalTo(50)
        }

        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }

        releaseButton.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(16)
            make.trailing.leading.equalToSuperview().inset(16)
        }

        recommendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(releaseButton.snp.bottom).offset(16)
        }

        creationButton.snp.makeConstraints { make in
            make.leading.equalTo(recommendButton.snp.trailing).offset(40)
            make.centerY.equalTo(recommendButton)
            make.bottom.equalToSuperview().inset(12)
        }

        recommendButton.addTarget(self, action: #selector(didTapRecommend), for: .touchUpInside)
        creationButton.addTarget(self, action: #selector(didTapCreation), for: .touchUpInside)
        releaseButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
    }

    @objc private func didTapCreate() {
        onCreateTapped?()
    }

    @objc private func didTapRecommend() {
        guard selectedTab != .recommend else { return }
        updateTabSelection(.recommend)
        onTabSelected?(.recommend)
    }

    @objc private func didTapCreation() {
        guard selectedTab != .creation else { return }
        updateTabSelection(.creation)
        onTabSelected?(.creation)
    }

    private let titleView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "live_title"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let topView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "live_icon"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var releaseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "live_create"), for: .normal)
        return button
    }()

    private let recommendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "live_recommend"), for: .normal)
        button.setImage(UIImage(named: "live_recommend_sel"), for: .selected)
        return button
    }()

    private let creationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "live_creation"), for: .normal)
        button.setImage(UIImage(named: "live_creation_sel"), for: .selected)
        return button
    }()
}
