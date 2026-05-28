//
//  DS_LiveVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_LiveVC: DS_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 230
        static let horizontalInset: CGFloat = 16
        static let itemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 12
        static let itemHeightRatio: CGFloat = 250.0 / 167.0
    }

    private let recommendItems: [DS_LiveRoomItem] = [
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Dance Power"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Making friends through dance"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Rhythm Resonance"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Dance Power"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Making friends through dance"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Rhythm Resonance")
    ]

    private let creationItems: [DS_LiveRoomItem] = [
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "EXPRESS YOUR"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "MOVES"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Dance Power"),
        DS_LiveRoomItem(coverImageName: nil, avatarImageNames: [nil, nil, nil], title: "Rhythm Resonance")
    ]

    private var currentTab: DS_LiveRoomListType = .recommend

    private var displayItems: [DS_LiveRoomItem] {
        switch currentTab {
        case .recommend:
            return recommendItems
        case .creation:
            return creationItems
        }
    }

    private let headerView = DS_LiveHeaderView()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.headerReferenceSize = CGSize(width: 0, height: Layout.headerHeight)
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 16,
            right: Layout.horizontalInset
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            DS_LiveRoomCell.self,
            forCellWithReuseIdentifier: DS_LiveRoomCell.reuseIdentifier
        )
        collectionView.register(
            DS_LiveHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DS_LiveHeaderReusableView.reuseIdentifier
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderReferenceSizeIfNeeded()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.onTabSelected = { [weak self] tab in
            self?.switchTab(to: tab)
        }

        headerView.onCreateTapped = { [weak self] in
            self?.navigationController?.pushViewController(DS_CreateLiveVC(), animated: true)
        }
    }

    private func switchTab(to tab: DS_LiveRoomListType) {
        guard currentTab != tab else { return }
        currentTab = tab
        collectionView.reloadData()
        scrollListToTop()
    }

    private func scrollListToTop() {
        let topOffsetY = -collectionView.adjustedContentInset.top
        collectionView.setContentOffset(CGPoint(x: 0, y: topOffsetY), animated: false)
    }

    private func itemSize(for collectionView: UICollectionView) -> CGSize {
        let totalHorizontalInset = Layout.horizontalInset * 2 + Layout.itemSpacing
        let width = (collectionView.bounds.width - totalHorizontalInset) / 2
        let height = width * Layout.itemHeightRatio
        return CGSize(width: floor(width), height: floor(height))
    }

    private var lastHeaderWidth: CGFloat = 0

    private func updateHeaderReferenceSizeIfNeeded() {
        let width = collectionView.bounds.width
        guard width > 0, width != lastHeaderWidth,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        lastHeaderWidth = width
        layout.headerReferenceSize = CGSize(width: width, height: Layout.headerHeight)
        layout.invalidateLayout()
    }
}

extension DS_LiveVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DS_LiveRoomCell.reuseIdentifier,
            for: indexPath
        ) as? DS_LiveRoomCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: displayItems[indexPath.item], listType: currentTab)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DS_LiveHeaderReusableView.reuseIdentifier,
                for: indexPath
              ) as? DS_LiveHeaderReusableView else {
            return UICollectionReusableView()
        }
        header.embed(headerView)
        headerView.updateTabSelection(currentTab)
        return header
    }
}

extension DS_LiveVC: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        itemSize(for: collectionView)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Layout.headerHeight)
    }
}
