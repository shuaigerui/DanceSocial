//
//  UserData.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import Foundation
import UIKit

/// 本地测试用户与媒体资源
enum UserData {

    /// 统一测试密码
    static let testPassword = "123456"

    /// 5 个本地测试账号
    static let users: [DS_UserModel] = [
        makeUser(
            index: 1,
            userName: "Marceline",
            account: "marceline@test.com",
            videoFile: "home_01.mp4",
            imageFile: "post_01.webp",
            chatRoomFile: "chatRoom_01.png",
            avatarFile: "avatar_01.png",
            goldCoins: 123123
        ),
        makeUser(
            index: 2,
            userName: "Luna",
            account: "luna@test.com",
            videoFile: "home_02.mp4",
            imageFile: "post_02.webp",
            chatRoomFile: "chatRoom_02.png",
            avatarFile: "avatar_02.png",
            goldCoins: 8800
        ),
        makeUser(
            index: 3,
            userName: "Beach",
            account: "beach@test.com",
            videoFile: "home_03.mp4",
            imageFile: "post_03.webp",
            chatRoomFile: "chatRoom_03.png",
            avatarFile: "avatar_03.png",
            goldCoins: 5200
        ),
        makeUser(
            index: 4,
            userName: "Nana",
            account: "nana@test.com",
            videoFile: "home_04.mp4",
            imageFile: "post_04.webp",
            chatRoomFile: "chatRoom_04.png",
            avatarFile: "avatar_04.png",
            goldCoins: 15000
        ),
        makeUser(
            index: 5,
            userName: "Trending",
            account: "trending@test.com",
            videoFile: "home_05.mp4",
            imageFile: "post_05.webp",
            chatRoomFile: "chatRoom_05.png",
            avatarFile: "avatar_05.png",
            goldCoins: 6666
        )
    ]

    static func user(userId: String) -> DS_UserModel? {
        users.first { $0.userId == userId }
    }

    static func allPosts() -> [DS_PostModel] {
        users.flatMap(\.posts)
    }

    static func allLiveRooms() -> [DS_LiveModel] {
        users.flatMap(\.createdLiveRooms)
    }

    // MARK: - Local media paths

    enum MediaFolder: String {
        case home = "Home"
        case post = "Post"
        case chatRoom = "ChatRoom"
        case avatar = "Avatar"
    }

    /// Bundle 内相对路径，写入 Model
    static func mediaPath(folder: MediaFolder, fileName: String) -> String {
        "Sources/\(folder.rawValue)/\(fileName)"
    }

    /// 根据 Bundle 路径、沙盒路径或 Assets 名称加载图片
    static func image(for path: String?) -> UIImage? {
        guard let path, !path.isEmpty else { return nil }

        if path.hasPrefix("/") {
            return UIImage(contentsOfFile: path)
        }

        if let url = mediaFileURL(path: path) {
            return UIImage(contentsOfFile: url.path)
        }

        let fileName = (path as NSString).lastPathComponent
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        if let url = Bundle.main.url(
            forResource: name,
            withExtension: ext.isEmpty ? nil : ext
        ) {
            return UIImage(contentsOfFile: url.path)
        }

        return UIImage(named: path) ?? UIImage(named: fileName)
    }

    /// 解析为可加载的 file URL（兼容 Sources 子目录与 Xcode 同步组扁平到 Bundle 根目录）
    static func mediaFileURL(path: String) -> URL? {
        let components = path.split(separator: "/").map(String.init)
        guard let fileName = components.last, !fileName.isEmpty else { return nil }

        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        let extensionArg: String? = ext.isEmpty ? nil : ext

        if components.count >= 2 {
            let subdirectory = components.dropLast().joined(separator: "/")
            if let url = Bundle.main.url(
                forResource: name,
                withExtension: extensionArg,
                subdirectory: subdirectory
            ) {
                return url
            }
        }

        return Bundle.main.url(forResource: name, withExtension: extensionArg)
    }

    // MARK: - Private

    private static func makeUser(
        index: Int,
        userName: String,
        account: String,
        videoFile: String,
        imageFile: String,
        chatRoomFile: String,
        avatarFile: String,
        goldCoins: Int
    ) -> DS_UserModel {
        let userId = "u_00\(index)"
        let avatarPath = mediaPath(folder: .avatar, fileName: avatarFile)
        let coverPath = mediaPath(folder: .chatRoom, fileName: chatRoomFile)
        let videoPath = mediaPath(folder: .home, fileName: videoFile)
        let imagePath = mediaPath(folder: .post, fileName: imageFile)

        let videoPost = DS_PostModel(
            postId: "p_\(userId)_video",
            userId: userId,
            userName: userName,
            avatarUrl: avatarPath,
            content: "Keep your promise to a winter snowfall and encounter freedom on the ski slopes.",
            mediaType: .video,
            mediaUrl: videoPath,
            videoCoverUrl: nil
        )

        let imagePost = DS_PostModel(
            postId: "p_\(userId)_image",
            userId: userId,
            userName: userName,
            avatarUrl: avatarPath,
            content: "Sharing a moment from the dance floor — rhythm, energy, and pure joy.",
            mediaType: .image,
            mediaUrl: imagePath
        )

        let liveRoom = DS_LiveModel(
            roomId: "r_\(userId)_001",
            title: "\(userName)'s Dance Room",
            coverUrl: coverPath,
            hostUserId: userId,
            hostUserName: userName,
            hostAvatarUrl: avatarPath,
            memberAvatarUrls: [avatarPath]
        )

        return DS_UserModel(
            userId: userId,
            account: account,
            password: testPassword,
            userName: userName,
            avatarUrl: avatarPath,
            coverUrl: coverPath,
            goldCoins: goldCoins,
            isBlack: false,
            isFollow: false,
            posts: [videoPost, imagePost],
            createdLiveRooms: [liveRoom]
        )
    }
}
