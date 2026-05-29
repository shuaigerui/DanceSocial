//
//  DS_ShopCatalog.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import Foundation

struct DS_ShopPackageItem: Hashable {
    let id: Int
    /// 展示用金额，如 99.99
    let priceValue: Decimal
    /// 钻石数（对应用户 goldCoins）
    let diamonds: Int
    /// App Store 商品 ID
    let productId: String

    var priceText: String {
        String(format: "$%.2f", NSDecimalNumber(decimal: priceValue).doubleValue)
    }

    var diamondsText: String {
        DS_ShopCatalog.formattedDiamonds(diamonds)
    }
}

enum DS_ShopCatalog {

    static let packages: [DS_ShopPackageItem] = [
        DS_ShopPackageItem(id: 0, priceValue: 99.99, diamonds: 63700, productId: "efliovaxtjayjxhw"),
        DS_ShopPackageItem(id: 1, priceValue: 49.99, diamonds: 29400, productId: "qqpnjnuywfvvfths"),
        DS_ShopPackageItem(id: 2, priceValue: 19.99, diamonds: 10800, productId: "ayuhjmouxaydrrqu"),
        DS_ShopPackageItem(id: 3, priceValue: 9.99, diamonds: 5150, productId: "sxaxnalzsxtgdbev"),
        DS_ShopPackageItem(id: 4, priceValue: 4.99, diamonds: 2450, productId: "vedcyzfeybajults"),
        DS_ShopPackageItem(id: 5, priceValue: 1.99, diamonds: 800, productId: "vzxjzqavbhnzksja"),
        DS_ShopPackageItem(id: 6, priceValue: 0.99, diamonds: 400, productId: "pbhoyslkidouauvl")
    ]

    static var productIds: Set<String> {
        Set(packages.map(\.productId))
    }

    static func package(for productId: String) -> DS_ShopPackageItem? {
        packages.first { $0.productId == productId }
    }

    static func diamonds(for productId: String) -> Int? {
        package(for: productId)?.diamonds
    }

    static func formattedDiamonds(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }
}
