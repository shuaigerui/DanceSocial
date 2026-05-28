//
//  DS_ProfileVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_ProfileVC: DS_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 650
    }

    private var feedItems: [DS_PostFeedItem] = []

    private let headerView = DS_ProfileHeaderView()

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
        guard let user = DS_CurrentUser.shared.user else { return }

        headerView.configure(with: user)

        feedItems = user.posts.map { post in
            DS_PostFeedItem(
                avatarImageName: post.avatarUrl,
                userName: post.userName,
                content: post.content,
                imagePath: post.isImage ? post.mediaUrl : nil,
                videoPath: post.isVideo ? post.mediaUrl : nil
            )
        }
        tableView.reloadData()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.onCoinShopTapped = { [weak self] in
            self?.navigationController?.pushViewController(DS_ShopVC(), animated: true)
        }

        headerView.onReviseTapped = { [weak self] in
            self?.navigationController?.pushViewController(DS_ReviseVC(), animated: true)
        }

        headerView.onSetupTapped = { [weak self] in
            self?.navigationController?.pushViewController(DS_SetupVC(), animated: true)
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

extension DS_ProfileVC: UITableViewDataSource {

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
        return cell
    }
}

extension DS_ProfileVC: UITableViewDelegate {
}
