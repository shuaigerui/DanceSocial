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

    /// 5 个本地测试账号（动态下含随机评论）
    static let users: [DS_UserModel] = buildPresetUsers()

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
        DS_CurrentUser.shared.allFeedPosts()
    }

    /// 本地副本缺少评论时，用预设数据里同 postId 的固定评论补足（不影响用户新发帖子）
    static func mergingPresetComments(into user: DS_UserModel, preset: DS_UserModel) -> DS_UserModel {
        guard user.userId == preset.userId else { return user }
        let presetByPostId = Dictionary(uniqueKeysWithValues: preset.posts.map { ($0.postId, $0) })
        let posts = user.posts.map { post -> DS_PostModel in
            guard post.comments.isEmpty,
                  let presetPost = presetByPostId[post.postId],
                  !presetPost.comments.isEmpty else {
                return post
            }
            return DS_PostModel(
                postId: post.postId,
                userId: post.userId,
                userName: post.userName,
                avatarUrl: post.avatarUrl,
                content: post.content,
                mediaType: post.mediaType,
                mediaUrl: post.mediaUrl,
                videoCoverUrl: post.videoCoverUrl,
                comments: presetPost.comments
            )
        }
        return DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: user.avatarUrl,
            coverUrl: user.coverUrl,
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: user.isFollow,
            posts: posts,
            createdLiveRooms: user.createdLiveRooms
        )
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

    // MARK: - Sandbox media paths（存相对路径，避免重启后绝对路径失效）

    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// 将沙盒文件 URL 转为相对 Documents 的路径，例如 `Posts/xxx.mp4`
    static func persistableMediaPath(for fileURL: URL) -> String {
        let docsPath = documentsDirectory.standardized.path
        let fullPath = fileURL.standardized.path
        if fullPath.hasPrefix(docsPath + "/") {
            return String(fullPath.dropFirst(docsPath.count + 1))
        }
        return fullPath
    }

    /// 将已保存的绝对路径规范为可持久化的相对路径
    static func normalizedPersistablePath(_ path: String?) -> String? {
        guard let path, !path.isEmpty else { return nil }

        if !path.hasPrefix("/") && !path.hasPrefix("file://") {
            return path
        }

        var filePath = path
        if path.hasPrefix("file://"), let url = URL(string: path) {
            filePath = url.path
        }

        if let relative = relativePathFromDocumentsAbsolute(filePath) {
            return relative
        }

        let docsPath = documentsDirectory.standardized.path
        if filePath.hasPrefix(docsPath + "/") {
            return String(filePath.dropFirst(docsPath.count + 1))
        }
        return filePath
    }

    private static func relativePathFromDocumentsAbsolute(_ absolutePath: String) -> String? {
        guard let range = absolutePath.range(of: "/Documents/") else { return nil }
        return String(absolutePath[range.upperBound...])
    }

    /// 解析媒体文件 URL（相对沙盒路径、历史绝对路径、Bundle 资源）
    static func resolveMediaFileURL(path: String) -> URL? {
        guard !path.isEmpty else { return nil }

        if !path.hasPrefix("/") && !path.hasPrefix("file://") {
            let sandboxURL = documentsDirectory.appendingPathComponent(path)
            if FileManager.default.fileExists(atPath: sandboxURL.path) {
                return sandboxURL
            }
            return bundleMediaFileURL(path: path)
        }

        var filePath = path
        if path.hasPrefix("file://"), let url = URL(string: path) {
            filePath = url.path
        }

        let directURL = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: directURL.path) {
            return directURL
        }

        if let relative = relativePathFromDocumentsAbsolute(filePath) {
            let sandboxURL = documentsDirectory.appendingPathComponent(relative)
            if FileManager.default.fileExists(atPath: sandboxURL.path) {
                return sandboxURL
            }
        }

        return bundleMediaFileURL(path: path)
    }

    /// 根据 Bundle 路径、沙盒路径或 Assets 名称加载图片
    static func image(for path: String?) -> UIImage? {
        guard let path, !path.isEmpty else { return nil }

        if let url = resolveMediaFileURL(path: path),
           FileManager.default.fileExists(atPath: url.path) {
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

    /// 解析为可加载的 file URL（兼容旧调用）
    static func mediaFileURL(path: String) -> URL? {
        resolveMediaFileURL(path: path)
    }

    private static func bundleMediaFileURL(path: String) -> URL? {
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

    /// 将用户数据中的沙盒媒体路径统一为相对路径（兼容历史绝对路径）
    static func migrateUserMediaPaths(_ user: DS_UserModel) -> DS_UserModel {
        let posts = user.posts.map { post in
            DS_PostModel(
                postId: post.postId,
                userId: post.userId,
                userName: post.userName,
                avatarUrl: post.avatarUrl,
                content: post.content,
                mediaType: post.mediaType,
                mediaUrl: normalizedPersistablePath(post.mediaUrl),
                videoCoverUrl: normalizedPersistablePath(post.videoCoverUrl),
                comments: post.comments
            )
        }

        let rooms = user.createdLiveRooms.map { room in
            DS_LiveModel(
                roomId: room.roomId,
                title: room.title,
                coverUrl: normalizedPersistablePath(room.coverUrl) ?? room.coverUrl,
                hostUserId: room.hostUserId,
                hostUserName: room.hostUserName,
                hostAvatarUrl: normalizedPersistablePath(room.hostAvatarUrl) ?? room.hostAvatarUrl,
                memberAvatarUrls: room.memberAvatarUrls.compactMap { normalizedPersistablePath($0) }
            )
        }

        return DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: normalizedPersistablePath(user.avatarUrl),
            coverUrl: normalizedPersistablePath(user.coverUrl),
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: user.isFollow,
            posts: posts,
            createdLiveRooms: rooms
        )
    }

    // MARK: - Private

    private static let postCommentPhrases: [String] = [
        "Love this energy!",
        "The beat is fire!",
        "So smooth, teach me that move!",
        "This made my day!",
        "Can't stop watching!",
        "Absolute vibes!",
        "You killed it!",
        "Need the full routine!",
        "Sharing this with my crew!",
        "The footwork is insane!",
        "More content like this please!",
        "Iconic performance!",
        "Who's the choreographer?",
        "Dropped a follow for this!",
        "Studio or street — both work!",
        "That transition was clean!",
        "Sending hype from the crowd!",
        "Practice goals right here.",
        "This room needs a remix!",
        "10/10 would dance again.",
        "Your timing is unreal!",
        "That freeze at the end though!",
        "Bookmarking for tonight's practice.",
        "The camera loves you.",
        "Main character energy.",
        "How many hours did you drill this?",
        "My legs hurt just watching.",
        "Clean lines all the way through.",
        "This deserves a spotlight.",
        "Replayed it five times already.",
        "The music pick is perfect.",
        "You make it look effortless.",
        "Teaching this in class tomorrow!",
        "Sharp hits, soft textures — chef's kiss.",
        "That level change was slick.",
        "Crowd would go wild for this live.",
        "Following for more tutorials.",
        "Your isolations are so crisp.",
        "Built different on that drop.",
        "Saving this for inspiration.",
        "The confidence is contagious.",
        "Wow, the musicality!",
        "Every beat accounted for.",
        "That hair whip was timed perfectly.",
        "Street style done right.",
        "Ballet training really shows here.",
        "K-pop fans approve.",
        "Hip-hop heads stand up!",
        "Jazz hands but make it modern.",
        "Contemporary flow on point.",
        "Breakdance roots showing!",
        "Latin flavor in the best way.",
        "Heels class material for sure.",
        "Waacking arms are everything.",
        "Popping levels are crazy good.",
        "Locking funk still hits.",
        "House steps on repeat.",
        "Afro beats meet the floor.",
        "Krump energy without the battle.",
        "Animation skills unlocked.",
        "Freestyle or choreo? Either way, fire.",
        "Tag your dance partner!",
        "Who else is stretching after this?",
        "Hydrate and hit replay.",
        "Monday motivation delivered.",
        "Weekend vibes unlocked.",
        "This is why I joined the app.",
        "Comment section full of talent.",
        "No notes, just applause.",
        "Chef's kiss to the editor too.",
        "Lighting and moves both slay.",
        "Outfit matches the choreography.",
        "That smile at the end won me over.",
        "Respect for filming and dancing!",
        "Next viral clip right here.",
        "Algorithm needs to push this.",
        "Shared to my dance group chat.",
        "Mom said she's proud (and she's right).",
        "Uncle at the wedding could never.",
        "School talent show winner vibes.",
        "Open mic night ready.",
        "Battle round one material.",
        "Finals week stress cure.",
        "Post-class serotonin boost.",
        "Mirror practice paid off!",
        "From the studio to the feed — love it.",
        "Sand, stage, or sidewalk — you deliver.",
        "Rainy day? This fixed it.",
        "Sunset session goals.",
        "Golden hour and golden moves.",
        "Night owls still dancing — respect.",
        "Early bird rehearsal energy.",
        "Team practice looking tight!",
        "Solo work never looked better.",
        "Duet when? I'd watch that.",
        "Trio formation please!",
        "The whole crew ate.",
        "Back row still visible — great staging.",
        "Front row energy from home.",
        "Subtle facials, huge impact.",
        "Storytelling through movement.",
        "Emotion hit before the last count.",
        "Chills on the last eight counts.",
        "Rewind the bridge again!",
        "Bass drop matched your hit — perfect.",
        "Slow section was surprisingly powerful.",
        "Speed change caught me off guard!",
        "Levels low to high — so dynamic.",
        "Traveling steps covered the whole space.",
        "Stillness in motion, love that contrast.",
        "Textures changed every phrase.",
        "Unison section was razor sharp.",
        "Canon moment was clever.",
        "Improv section felt authentic.",
        "Crowd call-and-response vibes.",
        "Encore! Encore!",
        "Standing ovation from my couch.",
        "Phone almost fell — too hyped.",
        "Neighbors probably heard me cheering.",
        "Added to my playlist immediately.",
        "Dance challenge accepted.",
        "Your turn — who's next?",
        "This trend needs your version.",
        "Original never goes out of style.",
        "Remix when? I'd listen.",
        "Acapella clip would slap too.",
        "Behind the scenes next please!",
        "Warm-up routine drop?",
        "Stretching tips in comments?",
        "What shoes are those?",
        "Floor work looked painless — teach us!",
        "Jumps were silent and soft.",
        "Landings were butter.",
        "Turn section was controlled.",
        "Balance held forever.",
        "Flexibility goals updated.",
        "Core strength showing.",
        "Partner trust level 100.",
        "Lift looked effortless (it's not).",
        "Gender-neutral choreo done beautifully.",
        "Inclusive energy in this piece.",
        "Kids in the back learning fast.",
        "Adults taking notes too.",
        "Never too late to start dancing.",
        "First month vs now — huge growth!",
        "Progress post when? We see the work.",
        "Consistency beats talent — you're proof.",
        "Rest day earned after this.",
        "Ice bath and repeat tomorrow.",
        "See you in the next live room!",
        "Booking a class because of you.",
        "Ticket sold if you perform live.",
        "Merch drop when?",
        "Fan account incoming.",
        "Not a dancer but I'm inspired.",
        "Started lessons today — thanks!",
        "My kids want to learn from you.",
        "Therapist said find joy — found it here.",
        "Bad day erased in 30 seconds.",
        "Good day made better.",
        "Sending this to my bestie.",
        "Group chat is exploding.",
        "Screenshot for the vision board.",
        "Wallpaper worthy frame at 0:12.",
        "Pause game strong on that pose.",
        "GIF material for sure.",
        "Emoji can't cover it — just 🔥.",
        "Heart button smashed.",
        "Notification squad reporting in.",
        "First comment? Couldn't resist.",
        "Lurker finally speaking up — wow.",
        "Returning after months — still elite.",
        "OG fan still here, still impressed.",
        "New here but already hooked.",
        "Following across every platform.",
        "Subscribed and bell on.",
        "Quality over quantity — you get it.",
        "Less posts, more impact — this proves it.",
        "Underrated no more.",
        "Hidden gem alert.",
        "Top of my For You today.",
        "Pinned-worthy content.",
        "Archive this for dance history.",
        "Museum piece movement.",
        "Poetry in sneakers.",
        "Sculpture in motion.",
        "Music video lead energy.",
        "Award show performance ready.",
        "Opening number material.",
        "Closing credits dance — yes please.",
        "Film festival short vibes.",
        "Documentary about you when?",
        "Biopic casting open?",
        "Stage name or real name — both work.",
        "Local legend going global.",
        "Hometown proud!",
        "Representing hard today.",
        "Flags in comments — where you from?",
        "International crew salute.",
        "Time zones don't stop the hype.",
        "3 a.m. scroll worth it.",
        "Lunch break well spent.",
        "Commute entertainment secured.",
        "Gym playlist updated.",
        "Cooking dinner, still watching.",
        "Multitasking failed — only watching you.",
        "One more rep then bed — lied, still here.",
        "Tomorrow's alarm ignored for this.",
        "Coffee spilled, worth it.",
        "Cat judged me, I don't care.",
        "Dog wagged along to the beat.",
        "Plant parent approved the vibe.",
        "Roommate asked who slayed — you.",
        "Bluetooth speaker on max.",
        "Headphones not enough — need speakers.",
        "Silent mode off for this track.",
        "Volume warning ignored.",
        "Bass boosted version needed.",
        "Clean audio mix compliments to team.",
        "Mic check on those breaths — pro.",
        "Live band version next?",
        "Strings would elevate this choreo.",
        "Drum solo section idea.",
        "Acoustic rewrite challenge?",
        "Lo-fi remix dreaming.",
        "Speed 0.5x still looks good.",
        "1.25x still clean — insane control.",
        "Frame by frame perfection.",
        "No missed counts spotted.",
        "Counting along — you didn't skip.",
        "Eight-count warriors unite.",
        "Five, six, seven, eight — let's go!",
        "And hold… beautiful.",
        "Recovery smooth after that burst.",
        "Breath control on point.",
        "Smile through the hard part — pro move.",
        "Sweat real, effort real, art real.",
        "Authenticity wins every time.",
        "Keep posting — we're watching.",
        "Don't stop now!",
        "More like this every week please.",
        "Series part two when?",
        "Collab list is long — pick me!",
        "Workshop tour dates?",
        "Masterclass sign-up link?",
        "Tips for beginners in caption?",
        "Breakdown video next?",
        "Slow motion tutorial please!",
        "Left side version too?",
        "Mirrored version for practice?",
        "Counts written anywhere?",
        "Sheet music drop?",
        "Costume change mid video — iconic.",
        "One take or multiple? Either way wow.",
        "BTS of the filming?",
        "Location scout did great.",
        "Weather didn't stop you.",
        "Indoor setup still cinematic.",
        "Outdoor power — wind and all.",
        "Parking lot legends.",
        "Rooftop session goals.",
        "Subway platform bravery.",
        "Mall flash mob memories.",
        "Wedding reception steal.",
        "Prom night redux.",
        "Graduation floor moment.",
        "Birthday surprise dance?",
        "Holiday special energy.",
        "Summer camp throwback.",
        "Winter showcase ready.",
        "Spring recital star.",
        "Fall festival headliner.",
        "Year-end recap candidate.",
        "Best of the month already.",
        "Quarterly highlight reel.",
        "Annual awards lock.",
        "Hall of fame entry.",
        "Legend status confirmed.",
        "Mic drop — no literally, encore!"
    ]

    private static func buildPresetUsers() -> [DS_UserModel] {
        let baseUsers: [DS_UserModel] = [
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
        return baseUsers.map { attachFixedComments(to: $0, allUsers: baseUsers) }
    }

    /// 预设动态固定 1~3 条评论（由 postId 决定，每次启动一致）
    private static func attachFixedComments(
        to user: DS_UserModel,
        allUsers: [DS_UserModel]
    ) -> DS_UserModel {
        let posts = user.posts.map { fixedCommentsPost($0, allUsers: allUsers) }
        return DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: user.avatarUrl,
            coverUrl: user.coverUrl,
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: user.isFollow,
            posts: posts,
            createdLiveRooms: user.createdLiveRooms
        )
    }

    private static let commentBaseTimestamp: TimeInterval = 1_704_067_200

    private static func stableHash(_ string: String) -> UInt64 {
        string.utf8.reduce(5381) { hash, byte in
            ((hash << 5) &+ hash) &+ UInt64(byte)
        }
    }

    private static func fixedCommentCount(for postId: String) -> Int {
        Int(stableHash(postId + "_n") % 3) + 1
    }

    private static func fixedCommentsPost(
        _ post: DS_PostModel,
        allUsers: [DS_UserModel]
    ) -> DS_PostModel {
        let commentators = allUsers.filter { $0.userId != post.userId }
        let comments = fixedComments(for: post, commentators: commentators)
        return DS_PostModel(
            postId: post.postId,
            userId: post.userId,
            userName: post.userName,
            avatarUrl: post.avatarUrl,
            content: post.content,
            mediaType: post.mediaType,
            mediaUrl: post.mediaUrl,
            videoCoverUrl: post.videoCoverUrl,
            comments: comments
        )
    }

    private static func fixedComments(
        for post: DS_PostModel,
        commentators: [DS_UserModel]
    ) -> [DS_PostCommentModel] {
        guard !commentators.isEmpty else { return [] }

        let count = fixedCommentCount(for: post.postId)
        let phraseCount = postCommentPhrases.count
        var comments: [DS_PostCommentModel] = []
        var usedPhraseIndices = Set<Int>()

        for index in 0..<count {
            let seed = stableHash("\(post.postId)_\(index)")
            let authorSeed = stableHash("\(post.postId)_author_\(index)")
            let author = commentators[Int(authorSeed % UInt64(commentators.count))]

            var phraseIndex = Int(
                (stableHash("\(post.postId)_phrase_\(index)") >> 4) % UInt64(phraseCount)
            )
            var offset = 0
            while usedPhraseIndices.contains(phraseIndex), offset < phraseCount {
                phraseIndex = (phraseIndex + Int(seed >> 12) + offset + 1) % phraseCount
                offset += 1
            }
            usedPhraseIndices.insert(phraseIndex)

            let hoursAgo = Double(count - index) * 2
            comments.append(
                DS_PostCommentModel(
                    commentId: "c_\(post.postId)_\(index + 1)",
                    userId: author.userId,
                    userName: author.userName,
                    avatarUrl: author.avatarUrl,
                    content: postCommentPhrases[phraseIndex],
                    createdAt: commentBaseTimestamp - hoursAgo * 3600
                )
            )
        }

        return comments.sorted { $0.createdAt < $1.createdAt }
    }

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
