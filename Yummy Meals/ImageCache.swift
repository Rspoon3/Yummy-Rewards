//
//  ImageCache.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import OSLog

final actor ImageCache {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ImageCache")
    private let cache = NSCache<NSString, StatusWrapper>()
    public static let shared = ImageCache()
    
    private init() {}
    
    enum ImageLoaderError: LocalizedError {
        case noImageData
        
        var errorDescription: String? {
            switch self {
            case .noImageData:
                return "Image data is missing"
            }
        }
    }
    
    private class StatusWrapper {
        let status: LoaderStatus
        
        init(_ status: LoaderStatus) {
            self.status = status
        }
    }

    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
        case failed(Error)
    }
    
    //MARK: - Public
    func clear() {
        cache.removeAllObjects()
    }

    public func fetch(_ url: String) async throws -> UIImage {
        let key = url as NSString
        
        if let wrapper = cache.object(forKey: key) {
            switch wrapper.status {
            case .inProgress(let task):
//                logger.debug("Task in progress please wait. Key: \(key)")
                return try await task.value
            case .fetched(let image):
//                logger.debug("Image previously fetched. Key: \(key)")
                return image
            case .failed(let error):
//                logger.debug("This request has previously failed. Key: \(key) Error: \(error.localizedDescription). ")
                throw error
            }
        }

        let task: Task<UIImage, Error> = Task {
            guard let url = URL(string: url) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else {
                let error = ImageLoaderError.noImageData
                throw error
            }
            
            return image
        }
        
//        logger.debug("Starting task. Key: \(key)")
        
        cache.setObject(StatusWrapper(.inProgress(task)), forKey: key)
        
        do {
            let image = try await task.value
            cache.setObject(StatusWrapper(.fetched(image)), forKey: key)
//            logger.debug("Successfully finishing the task. Key: \(key)")
            return image
        } catch {
//            logger.debug("Error fetching task. Key: \(key). Error: \(error.localizedDescription)")
            cache.setObject(StatusWrapper(.failed(error)), forKey: key)
            throw error
        }
    }
}
