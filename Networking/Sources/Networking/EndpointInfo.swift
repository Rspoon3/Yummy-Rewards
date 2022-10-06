//
//  EndpointInfo.swift
//  
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation


public struct EndpointInfo {
    let path: String
    let queryItem: URLQueryItem?
    
    init(_ path: String, queryItem: URLQueryItem? = nil) {
        self.path = path
        self.queryItem = queryItem
    }
}
