//
//  APIService.swift
//  
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation
import Combine


public struct APIService {
    private let apiVersion = "v1"
    private let apiKey = "1"
    private let decoder = JSONDecoder()
    public static let shared = APIService()
    
    
    //MARK: - Initializer
    private init() {}
    
    
    //MARK: - Public
    public func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let url = try createURL(for: endpoint)
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try decoder.decode(T.self, from: data)
    }
    
    public func publisher<T: Decodable>(endpoint: Endpoint, type: T.Type) -> AnyPublisher<T, Error> {
        do {
            let url = try createURL(for: endpoint)
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: T.self, decoder: decoder)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    
    //MARK: - Private Helpers
    private func createURL(for endpoint: Endpoint) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.themealdb.com"
        components.path = "/api/json/\(apiVersion)/\(apiKey)/\(endpoint.info.path).php"
        
        if let queryItem = endpoint.info.queryItem {
            components.queryItems = [queryItem]
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        return url
    }
}
