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

        guard let url = resolveVideoURL(for: videoPath) else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let image = generateFirstFrame(from: url)
            if let image {
                cache.setObject(image, forKey: cacheKey)
            }
            DispatchQueue.main.async {
                completion(image)
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

    private static func generateFirstFrame(from url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 600, height: 600)

        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
