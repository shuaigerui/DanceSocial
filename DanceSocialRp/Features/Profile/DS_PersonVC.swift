//
//  DS_PersonVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

class DS_PersonVC: DS_SecondaryVC {

    private let userId: String
    private var posts: [DS_PostModel] = []
    private var feedItems: [DS_PostFeedItem] = []
    private var personInfo: DS_PersonHeaderInfo

    private let headerView = DS_PersonHeaderView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            DS_PostFeedCell.self,
            forCellReuseIdentifier: DS_PostFeedCell.reuseIdentifier
        )
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()

    init(userId: String) {
        self.userId = userId
        let user = UserData.resolvedUser(userId: userId)
        self.personInfo = user.map(DS_PersonHeaderInfo.from(user:)) ?? .preview
        self.feedItems = user.map(UserData.feedItems(for:)) ?? []
        super.init(nibName: nil, bundle: nil)
    }

    init(personInfo: DS_PersonHeaderInfo, feedItems: [DS_PostFeedItem] = []) {
        self.userId = ""
        self.personInfo = personInfo
        self.feedItems = feedItems
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderIfNeeded()
    }

    private var isOwnProfile: Bool {
        guard !userId.isEmpty, let currentUserId = DS_CurrentUser.shared.user?.userId else {
            return false
        }
        return userId == currentUserId
    }

    private func loadData() {
        guard !userId.isEmpty, let user = UserData.resolvedUser(userId: userId) else { return }

        personInfo = DS_PersonHeaderInfo.from(user: user)
        posts = user.posts
        feedItems = UserData.feedItems(for: user)
        headerView.configure(with: personInfo, showsFollowAndChat: !isOwnProfile)
        tableView.reloadData()
        refreshTableHeaderLayout()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        headerView.onChatTapped = { [weak self] in
            guard let self else { return }
            let contact = DS_ChatRoomContact(
                name: self.personInfo.userName,
                avatarImageName: self.personInfo.avatarImageName
            )
            self.navigationController?.pushViewController(DS_ChatRoomVC(contact: contact), animated: true)
        }
    }

    private func setupTableHeader() {
        headerView.configure(with: personInfo, showsFollowAndChat: !isOwnProfile)
        refreshTableHeaderLayout()
    }

    private func updateTableHeaderIfNeeded() {
        let width = view.bounds.width
        guard width > 0 else { return }
        let height = measuredHeaderHeight(for: width)
        guard headerView.frame.width != width || abs(headerView.frame.height - height) > 0.5 else {
            return
        }
        applyTableHeaderSize(width: width, height: height)
    }

    private func refreshTableHeaderLayout() {
        let width = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        applyTableHeaderSize(width: width, height: measuredHeaderHeight(for: width))
    }

    private func measuredHeaderHeight(for width: CGFloat) -> CGFloat {
        headerView.setShowsFollowAndChat(!isOwnProfile)
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return ceil(height)
    }

    private func applyTableHeaderSize(width: CGFloat, height: CGFloat) {
        guard height > 0 else { return }
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = headerView
    }
}

extension DS_PersonVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_PostFeedCell.reuseIdentifier,
            for: indexPath
        ) as? DS_PostFeedCell else {
            return UITableViewCell()
        }
        let item = feedItems[indexPath.row]
        cell.configure(with: item)
        cell.onCommentTapped = { [weak self] in
            guard let self else { return }
            DS_PostCommentSheetVC.present(from: self)
        }
        cell.onMoreTapped = { [weak self] in
            guard let self, indexPath.row < self.posts.count else { return }
            let post = self.posts[indexPath.row]
            self.handlePostMoreTapped(post: post) { [weak self] in
                self?.loadData()
                self?.refreshTableHeaderLayout()
            }
        }
        return cell
    }
}

extension DS_PersonVC: UITableViewDelegate {
}
