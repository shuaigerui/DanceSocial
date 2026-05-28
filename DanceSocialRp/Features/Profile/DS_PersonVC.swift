//
//  DS_PersonVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

class DS_PersonVC: DS_SecondaryVC {

    private enum Layout {
        static let headerHeight: CGFloat = 650
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
        )
    ]

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
        return tableView
    }()

    private let personInfo: DS_PersonHeaderInfo

    init(personInfo: DS_PersonHeaderInfo = .preview) {
        self.personInfo = personInfo
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.configure(with: personInfo)
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

        headerView.onChatTapped = { [weak self] in
            guard let self else { return }
            let contact = DS_ChatRoomContact(
                name: self.personInfo.userName,
                avatarImageName: self.personInfo.avatarImageName ?? "chat_room"
            )
            self.navigationController?.pushViewController(DS_ChatRoomVC(contact: contact), animated: true)
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
        return cell
    }
}

extension DS_PersonVC: UITableViewDelegate {
}
