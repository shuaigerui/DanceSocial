//
//  DS_AIRommVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_AIRommVC: DS_SecondaryVC {

    private enum Layout {
        static let topBackgroundHeightRatio: CGFloat = 0.36
        static let chatTopCornerRadius: CGFloat = 24
        static let chatOverlap: CGFloat = 28
        static let inputBarHeight: CGFloat = 52
        static let inputHorizontalInset: CGFloat = 16
        static let sendButtonSize: CGFloat = 52
    }

    private var messages: [DS_AIChatMessage] = [
        DS_AIChatMessage(
            sender: .ai,
            text: "Hi, I'm your AI dance assistant. Feel free to ask me any dance questions or other concerns."
        ),
        DS_AIChatMessage(
            sender: .user,
            text: "Hello. What do you need your answerHello. What do you need your answer?"
        )
    ]

    private let topBackgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AI_top"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let chatContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            DS_AIChatMessageCell.self,
            forCellReuseIdentifier: DS_AIChatMessageCell.reuseIdentifier
        )
        return tableView
    }()

    private let inputBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let inputBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#333333")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        scrollToBottom(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chatContainerView.layer.cornerRadius = Layout.chatTopCornerRadius
        chatContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(topBackgroundImageView)
        view.addSubview(backButton)
        view.addSubview(chatContainerView)
        view.addSubview(inputBarView)

        chatContainerView.addSubview(tableView)
        inputBarView.addSubview(inputBackgroundView)
        inputBarView.addSubview(sendButton)
        inputBackgroundView.addSubview(messageTextField)

        topBackgroundImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(Layout.topBackgroundHeightRatio)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(4)
            make.width.height.equalTo(44)
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight + 16)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.inputHorizontalInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.sendButtonSize)
        }

        inputBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.inputHorizontalInset)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(Layout.inputBarHeight)
        }

        messageTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        chatContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topBackgroundImageView.snp.bottom).offset(-Layout.chatOverlap)
            make.bottom.equalTo(inputBarView.snp.top)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

    @objc private func didTapSend() {
        let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        messages.append(DS_AIChatMessage(sender: .user, text: text))
        messageTextField.text = nil
        tableView.reloadData()
        scrollToBottom(animated: true)
    }
}

extension DS_AIRommVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_AIChatMessageCell.reuseIdentifier,
            for: indexPath
        ) as? DS_AIChatMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

extension DS_AIRommVC: UITableViewDelegate {
}

extension DS_AIRommVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
