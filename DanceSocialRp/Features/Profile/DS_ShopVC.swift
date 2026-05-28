//
//  DS_ShopVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_ShopVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let itemSpacing: CGFloat = 7
        static let remainAspect: CGFloat = 276.0 / 1032.0
        static let packageAspect: CGFloat = 240.0 / 504.0
        static let confirmAspect: CGFloat = 192.0 / 801.0
        static let navBarHeight: CGFloat = 44
    }

    private var selectedPackageIndex = 0

    private let packages: [DS_ShopPackageItem] = (1...8).map {
        DS_ShopPackageItem(id: $0, amount: 12)
    }

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
        label.text = "Shop"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let remainImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "shop_remain"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "It can be used to post your moments and frustrations."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 14

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            DS_ShopPackageCell.self,
            forCellWithReuseIdentifier: DS_ShopPackageCell.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "shop_confirm"), for: .normal)
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(remainImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(collectionView)
        view.addSubview(confirmButton)

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

        remainImageView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(remainImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(25)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(confirmButton.snp.top).offset(-16)
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapConfirm() {
        // TODO: purchase selected package
    }
}

extension DS_ShopVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        packages.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DS_ShopPackageCell.reuseIdentifier,
            for: indexPath
        ) as? DS_ShopPackageCell else {
            return UICollectionViewCell()
        }
        cell.configure(
            with: packages[indexPath.item],
            isSelected: indexPath.item == selectedPackageIndex
        )
        return cell
    }
}

extension DS_ShopVC: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = Layout.itemSpacing
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedPackageIndex != indexPath.item else { return }
        let previousIndex = selectedPackageIndex
        selectedPackageIndex = indexPath.item
        collectionView.reloadItems(at: [
            IndexPath(item: previousIndex, section: 0),
            indexPath
        ])
    }
}
