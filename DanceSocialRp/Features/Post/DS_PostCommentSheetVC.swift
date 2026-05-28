//
//  DS_PostCommentSheetVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

final class DS_PostCommentSheetVC: UIViewController {

    private enum Layout {
        static let maxPanelHeight: CGFloat = 390
        static let topCornerRadius: CGFloat = 24
        static let horizontalInset: CGFloat = 16
        static let titleTopInset: CGFloat = 20
        static let titleHeight: CGFloat = 28
        static let inputBarHeight: CGFloat = 68
        static let inputFieldHeight: CGFloat = 52
        static let sendButtonSize: CGFloat = 52
    }

    private var comments: [DS_PostCommentItem] = [
        DS_PostCommentItem(
            avatarImageName: nil,
            userName: "Nana",
            text: "An hour agoAn hour agoAn hour agoAn hour agoAn hour agoAn hour ago"
        ),
        DS_PostCommentItem(
            avatarImageName: nil,
            userName: "Nana",
            text: "An hour agoAn hour agoAn hour agoAn hour agoAn hour agoAn hour ago"
        ),
        DS_PostCommentItem(
            avatarImageName: nil,
            userName: "Nana",
            text: "An hour agoAn hour agoAn hour agoAn hour agoAn hour agoAn hour ago"
        )
    ]

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    private let panelView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.topCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = UIColor(hex: "#858585", alpha: 0.4)
        return view
    }()

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: effect)
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Comment"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.register(
            DS_PostCommentCell.self,
            forCellReuseIdentifier: DS_PostCommentCell.reuseIdentifier
        )
        return tableView
    }()

    private let inputBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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

    private var panelBottomConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresent()
    }

    static func present(from viewController: UIViewController) {
        let sheet = DS_PostCommentSheetVC()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        viewController.present(sheet, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(dimmingView)
        view.addSubview(panelView)

        panelView.addSubview(blurView)
        panelView.addSubview(titleLabel)
        panelView.addSubview(tableView)
        panelView.addSubview(inputBarView)

        inputBarView.addSubview(inputBackgroundView)
        inputBarView.addSubview(sendButton)
        inputBackgroundView.addSubview(messageTextField)

        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        panelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            panelBottomConstraint = make.bottom.equalToSuperview().offset(Layout.maxPanelHeight).constraint
            make.height.equalTo(Layout.maxPanelHeight)
        }

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Layout.titleTopInset)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.titleHeight)
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Layout.sendButtonSize)
        }

        inputBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(Layout.inputFieldHeight)
        }

        messageTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDimming))
        dimmingView.addGestureRecognizer(tap)
    }

    private func animatePresent() {
        panelBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }

    private func dismissSheet() {
        panelBottomConstraint?.update(offset: Layout.maxPanelHeight)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimmingView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    @objc private func didTapDimming() {
        view.endEditing(true)
        dismissSheet()
    }

    @objc private func didTapSend() {
        let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        comments.append(DS_PostCommentItem(avatarImageName: nil, userName: "Me", text: text))
        messageTextField.text = nil
        tableView.reloadData()

        let lastRow = comments.count - 1
        guard lastRow >= 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
    }
}

extension DS_PostCommentSheetVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_PostCommentCell.reuseIdentifier,
            for: indexPath
        ) as? DS_PostCommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}

extension DS_PostCommentSheetVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
