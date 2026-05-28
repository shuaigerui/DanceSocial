//
//  DS_ChatRoomVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_ChatRoomContact {
    let name: String
    let avatarImageName: String?
}

class DS_ChatRoomVC: DS_SecondaryVC {

    private enum Layout {
        static let navBarContentHeight: CGFloat = 72
        static let headerAvatarSize: CGFloat = 44
        static let inputBarHeight: CGFloat = 52
        static let inputHorizontalInset: CGFloat = 16
        static let actionButtonSize: CGFloat = 52
    }

    private let contact: DS_ChatRoomContact

    private var messages: [DS_ChatRoomMessage] = [
        DS_ChatRoomMessage(
            sender: .peer,
            text: "Hello. What do I need your answerHello. What do I need your answer?"
        ),
        DS_ChatRoomMessage(
            sender: .me,
            text: "Hello. What do I need your answerHello. What do I need your answer?"
        )
    ]

    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "chat_more"), for: .normal)
        button.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        return button
    }()

    private let headerAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#3A3A3C")
        imageView.layer.cornerRadius = Layout.headerAvatarSize / 2
        return imageView
    }()

    private let headerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            DS_ChatRoomMessageCell.self,
            forCellReuseIdentifier: DS_ChatRoomMessageCell.reuseIdentifier
        )
        return tableView
    }()

    private let inputBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var videoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "chat_video"), for: .normal)
        button.addTarget(self, action: #selector(didTapVideo), for: .touchUpInside)
        return button
    }()

    private let inputBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#2C2C2E")
        view.layer.cornerRadius = 26
        view.clipsToBounds = true
        return view
    }()

    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter what you want to send",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.45),
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.returnKeyType = .send
        textField.delegate = self
        return textField
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_send"), for: .normal)
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        return button
    }()

    init(contact: DS_ChatRoomContact) {
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(contact: DS_ChatRoomContact(name: "Beach", avatarImageName: "chat_room"))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyContact()
        setupUI()
        scrollToBottom(animated: false)
    }

    private func applyContact() {
        headerNameLabel.text = contact.name
        if let avatarImageName = contact.avatarImageName,
           let image = UIImage(named: avatarImageName) {
            headerAvatarImageView.image = image
        }
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(tableView)
        view.addSubview(inputBarView)

        navBarView.addSubview(backButton)
        navBarView.addSubview(moreButton)
        navBarView.addSubview(headerAvatarImageView)
        navBarView.addSubview(headerNameLabel)

        inputBarView.addSubview(videoButton)
        inputBarView.addSubview(inputBackgroundView)
        inputBarView.addSubview(sendButton)
        inputBackgroundView.addSubview(messageTextField)

        navBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.navBarContentHeight)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(44)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(backButton)
            make.width.height.equalTo(44)
        }

        headerAvatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            make.width.height.equalTo(Layout.headerAvatarSize)
        }

        headerNameLabel.snp.makeConstraints { make in
            make.top.equalTo(headerAvatarImageView.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight + 16)
        }

        videoButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.inputHorizontalInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.actionButtonSize)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.inputHorizontalInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.actionButtonSize)
        }

        inputBackgroundView.snp.makeConstraints { make in
            make.leading.equalTo(videoButton.snp.trailing).offset(12)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(Layout.inputBarHeight)
        }

        messageTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMore() {
        // TODO: more actions
    }

    @objc private func didTapVideo() {
        let videoRoom = DS_VideoRoomVC(
            peerName: contact.name,
            peerAvatarPath: contact.avatarImageName
        )
        navigationController?.pushViewController(videoRoom, animated: true)
    }

    @objc private func didTapSend() {
        let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        messages.append(DS_ChatRoomMessage(sender: .me, text: text))
        messageTextField.text = nil
        tableView.reloadData()
        scrollToBottom(animated: true)
    }
}

extension DS_ChatRoomVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_ChatRoomMessageCell.reuseIdentifier,
            for: indexPath
        ) as? DS_ChatRoomMessageCell else {
            return UITableViewCell()
        }
        cell.configure(
            with: messages[indexPath.row],
            peerAvatarImageName: contact.avatarImageName,
            meAvatarImageName: "chat_room"
        )
        return cell
    }
}

extension DS_ChatRoomVC: UITableViewDelegate {
}

extension DS_ChatRoomVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
