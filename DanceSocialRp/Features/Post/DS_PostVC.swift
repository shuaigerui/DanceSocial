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

    private let feedItems: [DS_PostFeedItem] = [
        DS_PostFeedItem(
            avatarImageName: nil,
            userName: "Trending",
            content: "Keep your promise to a winter snowfall and encounter freedom on the ski slopes.",
            mediaImageName: nil
        ),
        DS_PostFeedItem(
            avatarImageName: nil,
            userName: "Trending",
            content: "Keep your promise to a winter snowfall and encounter freedom on the ski slopes.",
            mediaImageName: nil
        ),
        DS_PostFeedItem(
            avatarImageName: nil,
            userName: "Trending",
            content: "Keep your promise to a winter snowfall and encounter freedom on the ski slopes.",
            mediaImageName: nil
        )
    ]

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderIfNeeded()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        cell.configure(with: feedItems[indexPath.row])
        return cell
    }
}

extension DS_PostVC: UITableViewDelegate {
}
