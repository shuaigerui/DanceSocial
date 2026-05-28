//
//  DS_HomeHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_HomeHeaderView: UIView {

    var onAIBannerTapped: (() -> Void)?
    var onTeamItemTapped: ((DS_HomeTeamItem) -> Void)?

    private enum Layout {
        static let teamCollectionHeight: CGFloat = 168
        static let teamItemSize = CGSize(width: 108, height: 168)
        static let teamItemSpacing: CGFloat = 12
        static let horizontalInset: CGFloat = 16
    }

    private var teamItems: [DS_HomeTeamItem] = []

    private lazy var teamCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.teamItemSpacing
        layout.itemSize = Layout.teamItemSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            DS_HomeTeamCell.self,
            forCellWithReuseIdentifier: DS_HomeTeamCell.reuseIdentifier
        )
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBannerTap()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(topView)
        addSubview(titleView)
        addSubview(teamLabel)
        addSubview(teamCollectionView)
        addSubview(clipsLabel)

        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.top.equalToSuperview().offset(16)
        }

        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(28)
        }

        teamLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.top.equalTo(topView.snp.bottom).offset(16)
            make.height.equalTo(21)
        }

        teamCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(teamLabel.snp.bottom).offset(16)
            make.height.equalTo(Layout.teamCollectionHeight)
        }
        
        clipsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.top.equalTo(teamCollectionView.snp.bottom).offset(16)
            make.height.equalTo(21)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private let titleView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "home_title"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let topView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "home_top"))
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    func updateTeamItems(_ items: [DS_HomeTeamItem]) {
        teamItems = items
        teamCollectionView.reloadData()
    }

    private func setupBannerTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBannerTap))
        topView.addGestureRecognizer(tap)
    }

    @objc private func handleBannerTap() {
        onAIBannerTapped?()
    }

    private let teamLabel: UILabel = {
        let label = UILabel()
        label.text = "Dance team"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let clipsLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending Dance Clips"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
}

extension DS_HomeHeaderView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        teamItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DS_HomeTeamCell.reuseIdentifier,
            for: indexPath
        ) as? DS_HomeTeamCell else {
            return UICollectionViewCell()
        }
        let item = teamItems[indexPath.item]
        cell.configure(with: item)
        cell.onAvatarTapped = { [weak self] in
            self?.onTeamItemTapped?(item)
        }
        return cell
    }
}

extension DS_HomeHeaderView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < teamItems.count else { return }
        onTeamItemTapped?(teamItems[indexPath.item])
    }
}
