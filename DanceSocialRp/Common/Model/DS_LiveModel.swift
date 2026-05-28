//
//  DS_LiveModel.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import Foundation

/// 聊天室 / 直播房间
struct DS_LiveModel: Codable {

    let roomId: String
    /// 聊天室标题
    let title: String
    /// 封面图（单张）
    let coverUrl: String
    let hostUserId: String
    let hostUserName: String
    let hostAvatarUrl: String?
    /// 列表卡片展示的成员头像，通常 1~3 个
    let memberAvatarUrls: [String]

    init(
        roomId: String,
        title: String,
        coverUrl: String,
        hostUserId: String,
        hostUserName: String,
        hostAvatarUrl: String? = nil,
        memberAvatarUrls: [String] = []
    ) {
        self.roomId = roomId
        self.title = title
        self.coverUrl = coverUrl
        self.hostUserId = hostUserId
        self.hostUserName = hostUserName
        self.hostAvatarUrl = hostAvatarUrl
        self.memberAvatarUrls = memberAvatarUrls
    }
}

extension DS_LiveModel {

    /// 创建聊天室入参：标题 + 单张封面
    struct CreatePayload: Codable {
        let title: String
        let coverUrl: String
    }

    /// 本地创建草稿（上传封面前）
    struct Draft {
        var title: String
        var coverUrl: String?

        var isReadyToSubmit: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && coverUrl != nil
        }

        func makePayload() -> CreatePayload? {
            guard let coverUrl, isReadyToSubmit else { return nil }
            return CreatePayload(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                coverUrl: coverUrl
            )
        }
    }

    static func createPayload(title: String, coverUrl: String) -> CreatePayload {
        CreatePayload(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            coverUrl: coverUrl
        )
    }
}
