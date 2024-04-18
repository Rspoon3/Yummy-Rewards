//
//  CacheStatusWrapper.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/3/22.
//

import Foundation

class CacheStatusWrapper<T> {
    let status: CacheStatus<T>
    
    init(_ status: CacheStatus<T>) {
        self.status = status
    }
}

enum CacheStatus<T> {
    case inProgress(Task<T, Error>)
    case fetched(T)
    case failed(Error)
}
