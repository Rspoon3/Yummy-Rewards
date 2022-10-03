//
//  CacheStatusWrapper.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/3/22.
//

import Foundation

class CacheStatusWrapper<T> {
    let status: Status<T>
    
    init(_ status: Status<T>) {
        self.status = status
    }
    
    enum Status<T> {
        case inProgress(Task<T, Error>)
        case fetched(T)
        case failed(Error)
    }
}
