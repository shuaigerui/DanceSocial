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

    /// 预设用户 + 本地注册/更新后的用户
    static func resolvedUser(userId: String) -> DS_UserModel? {
        DS_CurrentUser.shared.resolvedUser(userId: userId) ?? user(userId: userId)
    }

    /// 他人主页顶部封面（聊天室封面，不用头像）
    static func personCoverPath(for user: DS_UserModel) -> String? {
        if let cover = user.coverUrl, !cover.isEmpty {
            return cover
        }
        return user.createdLiveRooms.first?.coverUrl
    }

    /// 预设 Bundle 视频对应的静态封面（home_01.mp4 → home_01_cover.jpg）
    static func bundleVideoCoverPath(forVideoPath path: String?) -> String? {
        guard let path, !path.isEmpty else { return nil }
        let fileName = (path as NSString).lastPathComponent
        guard fileName.hasSuffix(".mp4"), fileName.hasPrefix("home_") else { return nil }
        let coverName = fileName.replacingOccurrences(of: ".mp4", with: "_cover.jpg")
        return mediaPath(folder: .home, fileName: coverName)
    }

    static func bundleVideoCoverImage(forVideoPath path: String?) -> UIImage? {
        image(for: bundleVideoCoverPath(forVideoPath: path))
    }

    static func resolvedVideoCoverPath(for post: DS_PostModel) -> String? {
        guard post.isVideo else { return nil }
        if let cover = post.videoCoverUrl, !cover.isEmpty {
            return cover
        }
        return bundleVideoCoverPath(forVideoPath: post.mediaUrl)
    }

    static func feedItem(for post: DS_PostModel) -> DS_PostFeedItem {
        DS_PostFeedItem(
            postId: post.postId,
            userId: post.userId,
            avatarImageName: post.avatarUrl,
            userName: post.userName,
            content: post.content,
            imagePath: post.isImage ? post.mediaUrl : nil,
            videoPath: post.isVideo ? post.mediaUrl : nil,
            videoCoverPath: resolvedVideoCoverPath(for: post)
        )
    }

    static func feedItems(for user: DS_UserModel) -> [DS_PostFeedItem] {
        user.posts.map(feedItem(for:))
    }

    static func allPosts() -> [DS_PostModel] {
        users.flatMap(\.posts)
    }

    static func allLiveRooms() -> [DS_LiveModel] {
        users.flatMap(\.createdLiveRooms)
    }

    /// `Sources/Avatar` 下全部头像文件名
    static let avatarFileNames: [String] = (1...24).map { String(format: "avatar_%02d.png", $0) }

    /// 随机取若干不重复的头像路径
    static func randomAvatarPaths(count: Int, excluding existingPaths: [String] = []) -> [String] {
        guard count > 0 else { return [] }

        var exclude = Set(existingPaths)
        var pool = avatarFileNames
            .map { mediaPath(folder: .avatar, fileName: $0) }
            .filter { !exclude.contains($0) }

        var result: [String] = []
        var shuffled = pool.shuffled()

        while result.count < count {
            if shuffled.isEmpty {
                pool = avatarFileNames
                    .map { mediaPath(folder: .avatar, fileName: $0) }
                    .filter { !exclude.contains($0) }
                shuffled = pool.shuffled()
                if shuffled.isEmpty { break }
            }
            let path = shuffled.removeFirst()
            result.append(path)
            exclude.insert(path)
        }
        return result
    }

    /// 随机成员昵称
    static func randomMemberName() -> String {
        DS_GroupRoomScripts.randomMemberNames.randomElement() ?? "Guest"
    }

    /// 聊天室列表 3 个重叠头像：房主 + 随机成员头像
    static func liveRoomDisplayAvatarPaths(
        hostAvatarUrl: String?,
        memberAvatarUrls: [String] = []
    ) -> [String] {
        var paths: [String] = []
        if let host = hostAvatarUrl {
            paths.append(host)
        } else if let first = memberAvatarUrls.first {
            paths.append(first)
        }
        let fillers = randomAvatarPaths(count: max(0, 3 - paths.count), excluding: paths)
        paths.append(contentsOf: fillers)
        return Array(paths.prefix(3))
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
        let videoCoverPath = mediaPath(
            folder: .home,
            fileName: videoFile.replacingOccurrences(of: ".mp4", with: "_cover.jpg")
        )
        let imagePath = mediaPath(folder: .post, fileName: imageFile)

        let videoPost = DS_PostModel(
            postId: "p_\(userId)_video",
            userId: userId,
            userName: userName,
            avatarUrl: avatarPath,
            content: "Keep your promise to a winter snowfall and encounter freedom on the ski slopes.",
            mediaType: .video,
            mediaUrl: videoPath,
            videoCoverUrl: videoCoverPath
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
