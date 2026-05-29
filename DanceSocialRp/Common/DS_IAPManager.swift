//
//  DS_IAPManager.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import Foundation
import StoreKit

enum DS_IAPError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case verificationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not available"
        case .userCancelled:
            return "Purchase cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .verificationFailed:
            return "Purchase verification failed"
        case .unknown:
            return "Purchase failed"
        }
    }
}

@MainActor
final class DS_IAPManager {

    static let shared = DS_IAPManager()

    private var productsById: [String: Product] = [:]
    private var processedTransactionIDs = Set<UInt64>()
    private var updatesTask: Task<Void, Never>?

    private init() {
        startObservingTransactions()
    }

    func displayPrice(for productId: String) -> String? {
        productsById[productId]?.displayPrice
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: DS_ShopCatalog.productIds)
            productsById = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        } catch {
            productsById = [:]
        }
    }

    func purchase(productId: String) async throws -> Int {
        let product: Product
        if let cached = productsById[productId] {
            product = cached
        } else {
            let fetched = try await Product.products(for: [productId])
            guard let first = fetched.first else {
                throw DS_IAPError.productNotFound
            }
            productsById[productId] = first
            product = first
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verified(verification)
            let diamonds = try await deliverPurchase(for: transaction)
            return diamonds
        case .userCancelled:
            throw DS_IAPError.userCancelled
        case .pending:
            throw DS_IAPError.pending
        @unknown default:
            throw DS_IAPError.unknown
        }
    }

    private func startObservingTransactions() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                await self.handleTransactionUpdate(update)
            }
        }
    }

    private func handleTransactionUpdate(_ update: VerificationResult<Transaction>) async {
        guard let transaction = try? verified(update) else { return }
        _ = try? await deliverPurchase(for: transaction)
    }

    @discardableResult
    private func deliverPurchase(for transaction: Transaction) async throws -> Int {
        guard !processedTransactionIDs.contains(transaction.id) else {
            await transaction.finish()
            return 0
        }

        guard let diamonds = DS_ShopCatalog.diamonds(for: transaction.productID), diamonds > 0 else {
            await transaction.finish()
            return 0
        }

        processedTransactionIDs.insert(transaction.id)
        DS_CurrentUser.shared.addGoldCoins(diamonds)
        await transaction.finish()
        return diamonds
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw DS_IAPError.verificationFailed
        case .verified(let value):
            return value
        }
    }
}
