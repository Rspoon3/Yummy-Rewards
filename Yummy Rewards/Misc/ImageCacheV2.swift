//
//  ImageCacheV2.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 4/18/24.
//

import Foundation

final actor ImageCacheV2<T> {
    private let cache = NSCache<NSString, CacheStatusWrapper<T>>()
    
    //MARK: - Initializer
    private init() {}
    
    
    //MARK: - Public
    func clear() {
        cache.removeAllObjects()
    }

    public func fetch(_ url: String, action: @escaping () async throws -> T) async throws -> T {
        let key = url as NSString
        
        if let wrapper = cache.object(forKey: key) {
            switch wrapper.status {
            case .inProgress(let task):
                return try await task.value
            case .fetched(let image):
                return image
            case .failed(let error):
                throw error
            }
        }

        let task: Task<T, Error> = Task {
            try await action()
        }
        
        cache.setObject(CacheStatusWrapper(.inProgress(task)), forKey: key)
        
        do {
            let image = try await task.value
            cache.setObject(CacheStatusWrapper(.fetched(image)), forKey: key)
            return image
        } catch {
            cache.setObject(CacheStatusWrapper(.failed(error)), forKey: key)
            throw error
        }
    }
}
