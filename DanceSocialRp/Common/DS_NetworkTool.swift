//
//  DS_NetworkTool.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import Foundation
import SVProgressHUD

let urlPath = "https://test.fiveukmedia.xyz/le/afd/"

enum DS_NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case emptyBody

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpStatus(let code):
            return "Request failed (HTTP \(code))"
        case .emptyBody:
            return "Empty response body"
        }
    }
}

/// 默认 POST 接口工具（固定参数 five / six / nine）
final class DS_NetworkTool {

    static let shared = DS_NetworkTool()

    private static let defaultParameters: [String: String] = [
        "five": "66781AB9-7605-4AF8-9163-68D689792A93",
        "six": "1779788860268",
        "nine": "4450c8fb84d0cb7d9191921af247eceb942e63c33a65d7ee60a6cd80fc194442"
    ]

    private let session: URLSession
    private let timeout: TimeInterval = 30

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        session = URLSession(configuration: configuration)
    }

    /// 发起默认 POST 请求；`isShow` 为 true 时显示 HUD，成功 / 失败 / 超时后关闭
    func postDefaultRequest(
        isShow: Bool = true,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: urlPath) else {
            completion(.failure(DS_NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try? JSONSerialization.data(withJSONObject: Self.defaultParameters)

        if isShow {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }

        session.dataTask(with: request) { [weak self] data, response, error in
            self?.finishRequest(
                data: data,
                response: response,
                error: error,
                isShow: isShow,
                completion: completion
            )
        }.resume()
    }

    private func finishRequest(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        isShow: Bool,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let result: Result<Data, Error>

        if let error {
            result = .failure(error)
        } else if let http = response as? HTTPURLResponse,
                  !(200 ... 299).contains(http.statusCode) {
            result = .failure(DS_NetworkError.httpStatus(http.statusCode))
        } else if let data, !data.isEmpty {
            result = .success(data)
        } else if response != nil {
            result = .failure(DS_NetworkError.emptyBody)
        } else {
            result = .failure(DS_NetworkError.invalidResponse)
        }

        DispatchQueue.main.async {
            if isShow {
                SVProgressHUD.dismiss()
            }
            completion(result)
        }
    }
}
