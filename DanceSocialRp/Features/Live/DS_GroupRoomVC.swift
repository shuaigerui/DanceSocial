//
//  DS_GroupRoomVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

class DS_GroupRoomVC: DS_SecondaryVC {

    private enum Layout {
        static let navBarHeight: CGFloat = 44
        static let navActionSize: CGFloat = 40
        static let coverHeight: CGFloat = 256
        static let memberAvatarSize: CGFloat = 58
        static let memberAvatarOverlap: CGFloat = 10
        static let inputBarHeight: CGFloat = 52
        static let horizontalInset: CGFloat = 16
    }

    private let room: DS_LiveModel
    private let roomScriptIndex: Int

    private var messages: [DS_GroupRoomMessage] = []
    private var pendingAutoLines: [String] = []
    private var autoMessageTimer: Timer?

    private let headerContainerView = UIView()

    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Details"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "live_info"), for: .normal)
        button.addTarget(self, action: #selector(didTapInfo), for: .touchUpInside)
        return button
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "live_exit"), for: .normal)
        button.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        return button
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#1A1A1A")
        imageView.layer.cornerRadius = 24
        return imageView
    }()

    private let memberAvatarsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = -Layout.memberAvatarOverlap
        stack.alignment = .center
        return stack
    }()

    private let memberAvatarImageViews: [UIImageView] = (0..<3).map { _ in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            DS_GroupRoomMessageCell.self,
            forCellReuseIdentifier: DS_GroupRoomMessageCell.reuseIdentifier
        )
        return tableView
    }()

    private let inputBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
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

    init(room: DS_LiveModel, roomScriptIndex: Int) {
        self.room = room
        self.roomScriptIndex = roomScriptIndex
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyRoomInfo()
        setupMessages()
        setupUI()
        updateTableHeaderLayout()
        
        DS_NetworkTool.shared.postDefaultRequest { result in
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAutoMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoMessages()
    }

    private func applyRoomInfo() {
        coverImageView.image = UserData.image(for: room.coverUrl)
        let avatarPaths = UserData.liveRoomDisplayAvatarPaths(
            hostAvatarUrl: room.hostAvatarUrl,
            memberAvatarUrls: room.memberAvatarUrls
        )
        for (index, imageView) in memberAvatarImageViews.enumerated() {
            imageView.layer.cornerRadius = Layout.memberAvatarSize / 2
            let path = index < avatarPaths.count ? avatarPaths[index] : nil
            imageView.image = UserData.image(for: path)
        }
    }

    private func setupMessages() {
        messages = [.system(DS_GroupRoomScripts.welcomeMessage)]
        pendingAutoLines = DS_GroupRoomScripts.phrases(forRoomIndex: roomScriptIndex).shuffled()
    }

    private func setupUI() {
        view.backgroundColor = .black

        memberAvatarImageViews.forEach { memberAvatarsStackView.addArrangedSubview($0) }

        headerContainerView.addSubview(coverImageView)
        headerContainerView.addSubview(memberAvatarsStackView)

        view.addSubview(navBarView)
        view.addSubview(tableView)
        view.addSubview(inputBarView)

        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)
        navBarView.addSubview(infoButton)
        navBarView.addSubview(exitButton)

        inputBarView.addSubview(inputBackgroundView)
        inputBarView.addSubview(sendButton)
        inputBackgroundView.addSubview(messageTextField)

        tableView.tableHeaderView = headerContainerView

        navBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.navBarHeight)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        exitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.navActionSize)
        }

        infoButton.snp.makeConstraints { make in
            make.trailing.equalTo(exitButton.snp.leading).offset(-12)
            make.centerY.equalTo(exitButton)
            make.width.height.equalTo(Layout.navActionSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight + 16)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }

        inputBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
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

        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.coverHeight)
        }

        memberAvatarsStackView.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView)
            make.top.equalTo(coverImageView.snp.bottom).offset(14)
            make.bottom.equalToSuperview().inset(16)
        }

        memberAvatarImageViews.forEach { imageView in
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(Layout.memberAvatarSize)
            }
        }
    }

    private func updateTableHeaderLayout() {
        let width = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        headerContainerView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: 365
        )
        headerContainerView.layoutIfNeeded()
        tableView.tableHeaderView = headerContainerView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }

    // MARK: - Auto messages

    private func startAutoMessages() {
        stopAutoMessages()
        scheduleNextAutoMessage()
    }

    private func stopAutoMessages() {
        autoMessageTimer?.invalidate()
        autoMessageTimer = nil
    }

    private func scheduleNextAutoMessage() {
        guard !pendingAutoLines.isEmpty else { return }

        let isFirstMemberMessage = !messages.contains(where: { !$0.isSystem })
        let delay = TimeInterval.random(
            in: isFirstMemberMessage ? 1...4 : 3...8
        )
        autoMessageTimer = Timer.scheduledTimer(
            timeInterval: delay,
            target: self,
            selector: #selector(fireAutoMessage),
            userInfo: nil,
            repeats: false
        )
    }

    @objc private func fireAutoMessage() {
        guard !pendingAutoLines.isEmpty else { return }

        let text = pendingAutoLines.removeFirst()
        let avatarPath = UserData.randomAvatarPaths(count: 1).first
        let message = DS_GroupRoomMessage.member(
            userName: UserData.randomMemberName(),
            avatarPath: avatarPath,
            text: text
        )
        messages.append(message)
        tableView.reloadData()
        scrollToBottom(animated: true)
        scheduleNextAutoMessage()
    }

    private func scrollToBottom(animated: Bool) {
        let lastRow = messages.count - 1
        guard lastRow >= 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: animated)
    }

    // MARK: - Actions

    @objc private func didTapExit() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapInfo() {
        let alert = UIAlertController(
            title: room.title,
            message: "Hosted by \(room.hostUserName)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func didTapSend() {
        
        DS_NetworkTool.shared.postDefaultRequest(isShow: false) { result in
            switch result {
            case .success(_):
                self.sendAction()
            case .failure(_):
                self.sendAction()
            }
        }
    }
    
    private func sendAction(){
        
        let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        let me = DS_CurrentUser.shared.user
        let message = DS_GroupRoomMessage.member(
            userName: me?.userName ?? "Me",
            avatarPath: me?.avatarUrl,
            text: text
        )
        messages.append(message)
        messageTextField.text = nil
        tableView.reloadData()
        scrollToBottom(animated: true)
    }
}

extension DS_GroupRoomVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_GroupRoomMessageCell.reuseIdentifier,
            for: indexPath
        ) as? DS_GroupRoomMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

extension DS_GroupRoomVC: UITableViewDelegate {}

extension DS_GroupRoomVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
