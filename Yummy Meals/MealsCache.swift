//
//  MealsCache.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/2/22.
//

import Foundation
import Networking

final actor MealsCache {
    private let cache = NSCache<NSString, StatusWrapper>()
    public static let shared = MealsCache()
    
    private init() {}
    
    
    private class StatusWrapper {
        let status: LoaderStatus
        
        init(_ status: LoaderStatus) {
            self.status = status
        }
    }

    private enum LoaderStatus {
        case inProgress(Task<MealResponse, Error>)
        case fetched(MealResponse)
        case failed(Error)
    }
    
    //MARK: - Public
    func clear() {
        cache.removeAllObjects()
    }

    public func fetchMeals(for category: Category) async throws -> MealResponse {
        let key = category.title as NSString
        
        if let wrapper = cache.object(forKey: key) {
            switch wrapper.status {
            case .inProgress(let task):
                return try await task.value
            case .fetched(let response):
                return response
            case .failed(let error):
                throw error
            }
        }

        let task: Task<MealResponse, Error> = Task {
            let response: MealResponse = try await APIService.shared.fetch(endpoint: .meals(category: category.title))
            
            return response
        }
        
        
        cache.setObject(StatusWrapper(.inProgress(task)), forKey: key)
        
        do {
            let response = try await task.value
            cache.setObject(StatusWrapper(.fetched(response)), forKey: key)
            return response
        } catch {
            cache.setObject(StatusWrapper(.failed(error)), forKey: key)
            throw error
        }
    }
}
