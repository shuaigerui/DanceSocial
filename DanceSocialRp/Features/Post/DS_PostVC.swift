//
//  DS_PostVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_PostVC: DS_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 255
    }

    private var posts: [DS_PostModel] = []
    private var feedItems: [DS_PostFeedItem] = []

    private let headerView = DS_PostHeaderView()

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
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderIfNeeded()
    }

    private func loadData() {
        var posts = DS_CurrentUser.shared.allFeedPosts()
        if let user = DS_CurrentUser.shared.user,
           let resolved = DS_CurrentUser.shared.resolvedUser(userId: user.userId) {
            posts.removeAll { $0.userId == user.userId }
            posts.insert(contentsOf: resolved.posts, at: 0)
        }

        self.posts = posts
        feedItems = posts.map(UserData.feedItem(for:))
        tableView.reloadData()
    }
    
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.onReleaseTapped = { [weak self] in
            self?.navigationController?.pushViewController(DS_PushPostVC(), animated: true)
        }
    }

    private func setupTableHeader() {
        let width = UIScreen.main.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = headerView
    }

    private func updateTableHeaderIfNeeded() {
        let width = view.bounds.width
        guard width > 0 else { return }
        guard headerView.frame.width != width || headerView.frame.height != Layout.headerHeight else {
            return
        }
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = headerView
    }
}

extension DS_PostVC: UITableViewDataSource {

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
        cell.onAvatarTapped = { [weak self] in
            guard let self, indexPath.row < self.posts.count else { return }
            let userId = self.posts[indexPath.row].userId
            self.navigationController?.pushViewController(DS_PersonVC(userId: userId), animated: true)
        }
        cell.onCommentTapped = { [weak self] in
            guard let self, indexPath.row < self.posts.count else { return }
            DS_PostCommentSheetVC.present(from: self, post: self.posts[indexPath.row])
        }
        cell.onMoreTapped = { [weak self] in
            guard let self, indexPath.row < self.posts.count else { return }
            let post = self.posts[indexPath.row]
            self.handlePostMoreTapped(post: post) { [weak self] in
                self?.loadData()
            }
        }
        return cell
    }
}

extension DS_PostVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < posts.count else { return }

        let post = posts[indexPath.row]
        if post.isVideo {
            navigationController?.pushViewController(DS_VideoVC(post: post), animated: true)
        } else if post.isImage {
            navigationController?.pushViewController(DS_ImageVC(post: post), animated: true)
        }
    }
}
