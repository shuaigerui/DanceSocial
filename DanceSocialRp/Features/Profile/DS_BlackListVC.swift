//
//  DS_BlackListVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

class DS_BlackListVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let itemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 12
        static let navBarHeight: CGFloat = 44
        static let cancelAspect: CGFloat = 189.0 / 489.0
        static let topSectionRatio: CGFloat = 0.72
    }

    private var items: [DS_BlackListItem] = Array(
        repeating: DS_BlackListItem(avatarImageName: nil, userName: "Marceline"),
        count: 6
    )

    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Blacklist"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 8,
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
            DS_BlackListCell.self,
            forCellWithReuseIdentifier: DS_BlackListCell.reuseIdentifier
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(collectionView)

        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)

        navBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.navBarHeight)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func itemSize(for collectionView: UICollectionView) -> CGSize {
        let totalHorizontalInset = Layout.horizontalInset * 2 + Layout.itemSpacing
        let width = floor((collectionView.bounds.width - totalHorizontalInset) / 2)
        let height = width * Layout.cancelAspect + width * Layout.topSectionRatio
        return CGSize(width: width, height: height)
    }

    private func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        collectionView.reloadData()
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension DS_BlackListVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DS_BlackListCell.reuseIdentifier,
            for: indexPath
        ) as? DS_BlackListCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: items[indexPath.item])
        cell.onCancelTapped = { [weak self] in
            self?.removeItem(at: indexPath.item)
        }
        return cell
    }
}

extension DS_BlackListVC: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        itemSize(for: collectionView)
    }
}
