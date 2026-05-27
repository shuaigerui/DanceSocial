//
//  DS_ChatHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

enum DS_ChatTab: Int, CaseIterable {
    case chat
    case friend
    case ask

    var normalImageName: String {
        switch self {
        case .chat: return "seg_chat"
        case .friend: return "seg_friend"
        case .ask: return "seg_ask"
        }
    }

    var selectedImageName: String {
        switch self {
        case .chat: return "seg_chat_sel"
        case .friend: return "seg_friend_sel"
        case .ask: return "seg_ask_sel"
        }
    }
}

final class DS_ChatHeaderView: UIView {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let titleHeight: CGFloat = 32
        static let segmentHeight: CGFloat = 40
        static let segmentWidth: CGFloat = 82
    }

    var onTabSelected: ((DS_ChatTab) -> Void)?

    private(set) var selectedTab: DS_ChatTab = .chat

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    private lazy var segmentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [chatButton, friendButton, askButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private lazy var chatButton = makeSegmentButton(for: .chat)
    private lazy var friendButton = makeSegmentButton(for: .friend)
    private lazy var askButton = makeSegmentButton(for: .ask)

    private lazy var segmentButtons: [UIButton] = [chatButton, friendButton, askButton]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        updateTabSelection(.chat)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 116)
    }

    func updateTabSelection(_ tab: DS_ChatTab) {
        selectedTab = tab
        segmentButtons.enumerated().forEach { index, button in
            let buttonTab = DS_ChatTab(rawValue: index) ?? .chat
            button.isSelected = buttonTab == tab
        }
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(segmentStackView)

        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(25)
        }

        segmentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(Layout.segmentHeight)
            make.bottom.equalToSuperview().inset(12)
        }

        segmentButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.width.equalTo(Layout.segmentWidth)
                make.height.equalTo(Layout.segmentHeight)
            }
        }

        chatButton.addTarget(self, action: #selector(didTapChat), for: .touchUpInside)
        friendButton.addTarget(self, action: #selector(didTapFriend), for: .touchUpInside)
        askButton.addTarget(self, action: #selector(didTapAsk), for: .touchUpInside)
    }

    private func makeSegmentButton(for tab: DS_ChatTab) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: tab.normalImageName), for: .normal)
        button.setImage(UIImage(named: tab.selectedImageName), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = tab.rawValue
        return button
    }

    @objc private func didTapChat() {
        selectTab(.chat)
    }

    @objc private func didTapFriend() {
        selectTab(.friend)
    }

    @objc private func didTapAsk() {
        selectTab(.ask)
    }

    private func selectTab(_ tab: DS_ChatTab) {
        guard selectedTab != tab else { return }
        updateTabSelection(tab)
        onTabSelected?(tab)
    }
}
