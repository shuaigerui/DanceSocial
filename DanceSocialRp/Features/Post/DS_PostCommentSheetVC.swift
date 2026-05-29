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

    private let postId: String
    private var comments: [DS_PostCommentModel]

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
        tableView.register(
            SS_EmptyTableCell.self,
            forCellReuseIdentifier: SS_EmptyTableCell.reuseIdentifier
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

    init(post: DS_PostModel) {
        self.postId = post.postId
        self.comments = post.comments
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadComments()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresent()
    }

    static func present(from viewController: UIViewController, post: DS_PostModel) {
        let sheet = DS_PostCommentSheetVC(post: post)
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        viewController.present(sheet, animated: false)
    }

    private func reloadComments() {
        if let latest = DS_CurrentUser.shared.post(postId: postId) {
            comments = latest.comments
        }
        tableView.reloadData()
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

        guard DS_CurrentUser.shared.addComment(toPostId: postId, content: text) else { return }

        messageTextField.text = nil
        reloadComments()

        let lastRow = comments.count - 1
        guard lastRow >= 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
    }
}

extension DS_PostCommentSheetVC: UITableViewDataSource {

    private var isEmptyComments: Bool {
        comments.isEmpty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isEmptyComments ? 1 : comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmptyComments {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SS_EmptyTableCell.reuseIdentifier,
                for: indexPath
            ) as? SS_EmptyTableCell else {
                return UITableViewCell()
            }
            return cell
        }

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
