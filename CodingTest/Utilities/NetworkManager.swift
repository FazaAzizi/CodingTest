//
//  NetworkManager.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import Foundation
import Network
import Combine
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    func request<T: Decodable>(_ urlString: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> AnyPublisher<T, Error> {
        return AF.request(urlString, method: method, parameters: parameters)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { error -> Error in
                return NetworkError.afError(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func cancelAllRequests() {
        AF.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
}

enum NetworkError: Error {
    case noConnection
    case invalidURL
    case invalidResponse
    case afError(Error)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .afError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
