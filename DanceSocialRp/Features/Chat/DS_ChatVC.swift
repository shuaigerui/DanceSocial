//
//  DS_ChatVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_ChatVC: DS_BaseVC {

    private var currentTab: DS_ChatTab = .chat

    private var messageItems: [DS_ChatMessageItem] = []

    private var friendItems: [DS_ChatFriendItem] = []
    private var askItems: [DS_ChatAskItem] = []

    private let headerView = DS_ChatHeaderView()
    private var emptyView = DS_EmptyView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DS_ChatMessageCell.self, forCellReuseIdentifier: DS_ChatMessageCell.reuseIdentifier)
        tableView.register(DS_ChatFriendCell.self, forCellReuseIdentifier: DS_ChatFriendCell.reuseIdentifier)
        tableView.register(DS_ChatAskCell.self, forCellReuseIdentifier: DS_ChatAskCell.reuseIdentifier)
        return tableView
    }()
    
    private func loadData() {
        if let currentUserId = DS_CurrentUser.shared.user?.userId {
            messageItems = DS_ChatStore.chatMessageItems(currentUserId: currentUserId)
                .filter { !DS_CurrentUser.shared.isUserBlacklisted(userId: $0.userId) }
        } else {
            messageItems = []
        }
        friendItems = DS_CurrentUser.shared.chatFriendItems()
        askItems = DS_CurrentUser.shared.chatAskItems()
        emptyView.isHidden = currentRowCount > 0
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layoutTableHeader()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableHeader()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(30)
        }
        headerView.onTabSelected = { [weak self] tab in
            self?.switchTab(to: tab)
        }
    }

    private func layoutTableHeader() {
        let width = view.bounds.width
        guard width > 0 else { return }

        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let finalHeight = max(ceil(height), headerView.intrinsicContentSize.height)
        guard headerView.frame.height != finalHeight else { return }

        headerView.frame.size.height = finalHeight
        tableView.tableHeaderView = nil
        tableView.tableHeaderView = headerView
    }

    private func switchTab(to tab: DS_ChatTab) {
        guard currentTab != tab else { return }
        currentTab = tab
        headerView.updateTabSelection(tab)
        emptyView.isHidden = currentRowCount > 0
        tableView.reloadData()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
    }

    private var currentRowCount: Int {
        switch currentTab {
        case .chat:
            return messageItems.count
        case .friend:
            return friendItems.count
        case .ask:
            return askItems.count
        }
    }
}

extension DS_ChatVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentRowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentTab {
        case .chat:
            return makeMessageCell(tableView: tableView, indexPath: indexPath)
        case .friend:
            return makeFriendCell(tableView: tableView, indexPath: indexPath)
        case .ask:
            return makeAskCell(tableView: tableView, indexPath: indexPath)
        }
    }

    private func makeMessageCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_ChatMessageCell.reuseIdentifier,
            for: indexPath
        ) as? DS_ChatMessageCell else {
            return UITableViewCell()
        }
        let item = messageItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    private func openChatRoom(with item: DS_ChatMessageItem) {
        guard ds_guardMutualFollowForChat(peerUserId: item.userId) else { return }
        navigationController?.pushViewController(
            DS_ChatRoomVC(contact: DS_ChatRoomContact(messageItem: item)),
            animated: true
        )
    }

    private func openChatRoom(with friend: DS_ChatFriendItem) {
        guard ds_guardMutualFollowForChat(peerUserId: friend.userId) else { return }
        navigationController?.pushViewController(
            DS_ChatRoomVC(contact: DS_ChatRoomContact(friend: friend)),
            animated: true
        )
    }

    private func makeFriendCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_ChatFriendCell.reuseIdentifier,
            for: indexPath
        ) as? DS_ChatFriendCell else {
            return UITableViewCell()
        }
        let item = friendItems[indexPath.row]
        cell.configure(with: item)
        cell.onChatTapped = { [weak self] in
            self?.openChatRoom(with: item)
        }
        return cell
    }

    private func makeAskCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DS_ChatAskCell.reuseIdentifier,
            for: indexPath
        ) as? DS_ChatAskCell else {
            return UITableViewCell()
        }
        let item = askItems[indexPath.row]
        cell.configure(with: item)
        cell.onFollowTapped = { [weak self] in
            self?.toggleFollow(at: indexPath.row)
        }
        return cell
    }

    private func toggleFollow(at index: Int) {
        guard askItems.indices.contains(index) else { return }
        let item = askItems[index]
        DS_CurrentUser.shared.toggleFollow(userId: item.userId, isFollow: item.isFollowing)
        loadData()
    }
}

extension DS_ChatVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard currentTab == .chat else { return }
        openChatRoom(with: messageItems[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard currentTab == .chat else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self, self.messageItems.indices.contains(indexPath.row) else {
                completion(false)
                return
            }
            let item = self.messageItems[indexPath.row]
            if let currentUserId = DS_CurrentUser.shared.user?.userId {
                DS_ChatStore.deleteConversation(currentUserId: currentUserId, peerUserId: item.userId)
            }
            self.loadData()
            completion(true)
        }

        deleteAction.image = UIImage(named: "chat_del")
        deleteAction.backgroundColor = UIColor.hex("#FF3B30")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
