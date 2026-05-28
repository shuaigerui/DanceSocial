//
//  DS_VideoThumbnailLoader.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import AVFoundation
import UIKit

/// 从本地视频生成首帧封面（带内存缓存）
enum DS_VideoThumbnailLoader {

    private static let cache = NSCache<NSString, UIImage>()

    static func thumbnail(for videoPath: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = videoPath as NSString
        if let cached = cache.object(forKey: cacheKey) {
            completion(cached)
            return
        }

        if let bundled = UserData.bundleVideoCoverImage(forVideoPath: videoPath) {
            cache.setObject(bundled, forKey: cacheKey)
            completion(bundled)
            return
        }

        guard resolveVideoURL(for: videoPath) != nil else {
            completion(nil)
            return
        }

        Task {
            let image = await generateFirstFrame(for: videoPath)
            if let image {
                cache.setObject(image, forKey: cacheKey)
            }
            await MainActor.run {
                completion(image)
            }
        }
    }

    /// 同步生成封面（发帖保存封面等场景）
    static func thumbnailImage(for videoPath: String) -> UIImage? {
        let cacheKey = videoPath as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        if let bundled = UserData.bundleVideoCoverImage(forVideoPath: videoPath) {
            cache.setObject(bundled, forKey: cacheKey)
            return bundled
        }

        guard let image = generateFirstFrameSynchronously(for: videoPath) else {
            return nil
        }
        cache.setObject(image, forKey: cacheKey)
        return image
    }

    private static func generateFirstFrame(for videoPath: String) async -> UIImage? {
        guard let url = resolveVideoURL(for: videoPath) else { return nil }

        let asset = AVURLAsset(url: url)
        do {
            let tracks = try await asset.load(.tracks)
            guard !tracks.isEmpty else { return nil }
            return await extractFrame(from: asset)
        } catch {
            return nil
        }
    }

    private static func generateFirstFrameSynchronously(for videoPath: String) -> UIImage? {
        var result: UIImage?
        DispatchQueue.global(qos: .userInitiated).sync {
            let group = DispatchGroup()
            group.enter()
            Task {
                result = await generateFirstFrame(for: videoPath)
                group.leave()
            }
            group.wait()
        }
        return result
    }

    private static func extractFrame(from asset: AVURLAsset) async -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 1280, height: 1280)
        generator.requestedTimeToleranceBefore = .positiveInfinity
        generator.requestedTimeToleranceAfter = .positiveInfinity

        var candidateSeconds: [Double] = [0.5, 0.1, 0, 1.0, 2.0]
        if let duration = try? await asset.load(.duration) {
            let total = CMTimeGetSeconds(duration)
            if total.isFinite, total > 2 {
                candidateSeconds.append(total * 0.25)
            }
        }

        for seconds in candidateSeconds {
            let time = CMTime(seconds: seconds, preferredTimescale: 600)
            if let image = try? await generateImage(generator: generator, at: time) {
                return image
            }
            if let image = await generateImageAsync(generator: generator, at: time) {
                return image
            }
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }

    private static func generateImage(
        generator: AVAssetImageGenerator,
        at time: CMTime
    ) async throws -> UIImage {
        let cgImage = try await generator.image(at: time).image
        return UIImage(cgImage: cgImage)
    }

    private static func generateImageAsync(
        generator: AVAssetImageGenerator,
        at time: CMTime
    ) async -> UIImage? {
        await withCheckedContinuation { continuation in
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
                _, cgImage, _, result, _ in
                if result == .succeeded, let cgImage {
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private static func resolveVideoURL(for path: String) -> URL? {
        if path.hasPrefix("/") {
            let fileURL = URL(fileURLWithPath: path)
            return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
        }
        return UserData.mediaFileURL(path: path)
    }
}
