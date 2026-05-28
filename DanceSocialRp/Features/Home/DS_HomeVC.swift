//
//  DS_HomeVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_HomeVC: DS_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let itemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 12
        static let itemHeightRatio: CGFloat = 250.0 / 167.0
    }

    private var clipItems: [DS_HomeClipItem] = []
    private var videoPosts: [DS_PostModel] = []

    private let headerView = DS_HomeHeaderView()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
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
            DS_HomeClipCell.self,
            forCellWithReuseIdentifier: DS_HomeClipCell.reuseIdentifier
        )
        collectionView.register(
            DS_HomeHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DS_HomeHeaderReusableView.reuseIdentifier
        )
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        invalidateHeaderLayoutIfNeeded()
    }
    
    private func loadData() {
        let teamItems = UserData.allLiveRooms().map { room in
            DS_HomeTeamItem(
                coverImageName: room.coverUrl,
                avatarImageName: room.hostAvatarUrl,
                title: room.title
            )
        }

        videoPosts = UserData.allPosts().filter(\.isVideo)
        clipItems = videoPosts.map { post in
            DS_HomeClipItem(
                videoPath: post.mediaUrl,
                avatarImageName: post.avatarUrl,
                title: post.userName
            )
        }

        headerView.updateTeamItems(teamItems)
        collectionView.reloadData()

        lastHeaderSize = .zero
        invalidateHeaderLayoutIfNeeded()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.onAIBannerTapped = { [weak self] in
            self?.navigationController?.pushViewController(DS_AIRommVC(), animated: true)
        }
    }

    private func itemSize(for collectionView: UICollectionView) -> CGSize {
        let totalHorizontalInset = Layout.horizontalInset * 2 + Layout.itemSpacing
        let width = (collectionView.bounds.width - totalHorizontalInset) / 2
        let height = width * Layout.itemHeightRatio
        return CGSize(width: floor(width), height: floor(height))
    }

    private func headerSize(for collectionView: UICollectionView) -> CGSize {
        let width = collectionView.bounds.width
        guard width > 0 else { return .zero }

        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        return CGSize(width: width, height: ceil(height))
    }

    private var lastHeaderSize: CGSize = .zero

    private func invalidateHeaderLayoutIfNeeded() {
        let size = headerSize(for: collectionView)
        guard size != lastHeaderSize, size.height > 0 else { return }
        lastHeaderSize = size

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = size
            layout.invalidateLayout()
        }
    }
}

extension DS_HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        clipItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DS_HomeClipCell.reuseIdentifier,
            for: indexPath
        ) as? DS_HomeClipCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: clipItems[indexPath.item])
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
                withReuseIdentifier: DS_HomeHeaderReusableView.reuseIdentifier,
                for: indexPath
              ) as? DS_HomeHeaderReusableView else {
            return UICollectionReusableView()
        }
        header.embed(headerView)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < videoPosts.count else { return }
        let videoVC = DS_VideoVC(post: videoPosts[indexPath.item])
        navigationController?.pushViewController(videoVC, animated: true)
    }
}

extension DS_HomeVC: UICollectionViewDelegateFlowLayout {

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
        headerSize(for: collectionView)
    }
}
